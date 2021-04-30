#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../config/environment"

require "open-uri"
require "json"

CURRENT_PATH = Pathname.new File.expand_path(__dir__)
JS_APP_PATH = CURRENT_PATH.join("..", "vendor", "polkadot_js_snippets")

CHAIN_ENDPOINTS = {
  dev: "http://127.0.0.1:9933", # "ws://127.0.0.1:9944"
  kusama: "http://127.0.0.1:9933" # "ws://127.0.0.1:9944"
}.with_indifferent_access

current_chain = ARGV[0]
unless CHAIN_ENDPOINTS[current_chain]
  raise "Unknown chain `#{current_chain}`"
end

start_block_num = State.start_block_num(chain: current_chain)
current_block_num = State.current_block_num(chain: current_chain)

if current_block_num.integer_value < start_block_num.integer_value
  current_block_num.update_attribute :integer_value, start_block_num.integer_value
end

loop do
  puts "Fetching chain `#{current_chain}` contribution events at block num #{current_block_num.integer_value}"
  out = URI.open("http://127.0.0.1:3001/fetch_block/#{current_block_num.integer_value}").read rescue nil
  if out.blank? || out == "{}"
    puts "No output, sleep 5s..."
    sleep 5
    next
  end

  jsonify_out = JSON.parse out
  pp jsonify_out

  raw_timestamp = jsonify_out.fetch("timestamp").to_i / 1000
  raise "Timestamp is 0" if raw_timestamp.zero?
  timestamp = Time.at(raw_timestamp)

  fund_infos =
    if current_block_num.integer_value % 10 == 0
      o = URI.open("http://127.0.0.1:3001/fund_infos?block_number=#{current_block_num.integer_value}").read rescue nil

      JSON.parse o rescue nil
    end
  pp fund_infos if fund_infos.present?

  contribution_events = jsonify_out.fetch("contributions").map do |item|
    {
      chain: current_chain,
      block_num: current_block_num.integer_value,
      who: item.fetch("who"),
      fund_index: item.fetch("fund_index"),
      amount: item.fetch("amount").to_s.to_d,
      on_chain_hash: current_block_num.integer_value,
      timestamp: timestamp,
      created_at: Time.zone.now
    }
  end

  remark_referrer_events = jsonify_out.fetch("referrer_remarks").map do |item|
    {
      chain: current_chain,
      block_num: current_block_num.integer_value,
      who: item.fetch("who"),
      para_id: item.fetch("para_id"),
      referrer: item.fetch("referrer"),
      on_chain_hash: current_block_num.integer_value,
      timestamp: timestamp,
      created_at: Time.zone.now
    }
  end

  referrer_remarks = jsonify_out.fetch("referrer_remarks")

  ApplicationRecord.transaction do
    contribution_events.each do |item|
      event = ContributionEvent.create! item
      event.process!
    end

    remark_referrer_events.each do |item|
      event = RemarkReferrerEvent.create! item
      event.process!
    end

    Campaign
      .where("start_block <= ? AND end_block >= ?", current_block_num.integer_value, current_block_num.integer_value)
      .each do |campaign|
        nearest_hour = timestamp.beginning_of_hour
        nearest_hour = nearest_hour - (nearest_hour.hour % 4).hour
        campaign.hourly_contributions.find_or_create_by! timestamp: nearest_hour do |record|
          last_hour = campaign.hourly_contributions.order(timestamp: :desc).first
          record.amount = last_hour&.amount || 0
        end
      end

    if fund_infos
      # {"2,000":{"deposit":100,"raised":100,"cap":150000,"end":20000,"depositor":"5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY"}}
      Competitor.update_all raised_amount: 0
      fund_infos.each do |k, v|
        k = k.to_s.gsub(",", "") # Workaround
        # TODO: May not get the final state, but not to critical I think
        Competitor
          .where("parachain_ids LIKE '%#{k}%'")
          .where("start_block <= ? AND end_block >= ?", current_block_num.integer_value, current_block_num.integer_value)
          .each do |competitor|
            competitor.increment! :raised_amount, v.fetch("raised").to_s.to_d
          end
      end
    end

    current_block_num.update_attribute :integer_value, current_block_num.integer_value + 1
  end

  if remark_referrer_events.size > 0 || contribution_events.size > 0
    puts "#{contribution_events.size} contribution events inserted, #{referrer_remarks.size} referrer set."
  end
end
