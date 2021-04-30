#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../config/environment"

require "json"

CURRENT_PATH = Pathname.new File.expand_path(__dir__)
JS_APP_PATH = CURRENT_PATH.join("..", "vendor", "polkadot_js_snippets")

CHAIN_ENDPOINTS = {
  dev: "http://127.0.0.1:9933" # "ws://127.0.0.1:9944"
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
  out =
    Dir.chdir JS_APP_PATH do
      `node get_contribution_events.js --block-number=#{current_block_num.integer_value} --endpoint="#{CHAIN_ENDPOINTS[current_chain]}"`
    end.strip

  if out.blank?
    puts "No output, sleep 5s..."
    sleep 5
    next
  end

  jsonify_out = JSON.parse out
  pp jsonify_out

  if jsonify_out.empty?
    current_block_num.update_attribute :integer_value, current_block_num.integer_value + 1
    next
  end

  items = jsonify_out.map do |item|
    {
      chain: current_chain,
      block_num: current_block_num.integer_value,
      who: item.fetch("who"),
      fund_index: item.fetch("fund_index"),
      amount: item.fetch("amount"),
      created_at: Time.zone.now
    }
  end

  # ContributionEvent.insert_all! items
  ApplicationRecord.transaction do
    items.each do |item|
      event = ContributionEvent.create! item
      event.process!
    end

    current_block_num.update_attribute :integer_value, current_block_num.integer_value + 1
  end

  puts "#{items.size} contribution events inserted"
end
