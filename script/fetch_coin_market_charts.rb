#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../config/environment"

require "json"
require "net/http"

URL_PATTERN = "https://api.coingecko.com/api/v3/coins/{TOKEN}/market_chart?vs_currency=usd&days=14&interval=hourly"
TOKENS = {
  "kusama" => "KSM",
  "pha" => "PHA",
  "polkadot" => "DOT"
}

puts "Running at #{Time.zone.now}"

TOKENS.each do |token, symbol|
  puts "Fetching #{symbol} hourly data"

  uri = URI(URL_PATTERN.gsub("{TOKEN}", token))
  # Create client
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_PEER

  # Create Request
  req = Net::HTTP::Get.new(uri)
  # Add headers
  req.add_field "Accept", "application/json"
  # Fetch Request
  res = http.request(req)

  prices = JSON.parse(res.body).fetch("prices")
  # pp prices

  prices.map! do |row|
    {
      symbol: symbol,
      timestamp: Time.at(row[0] / 1000),
      price: row[1].truncate(4)
    }
  end

  CoinMarketChart.where(symbol: symbol).delete_all
  CoinMarketChart.insert_all! prices
end
