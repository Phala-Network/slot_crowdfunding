# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    render json: {
      status: "ok"
    }
  end

  def ping
    current_block_nums =
      State
        .where(key: "current_block_num")
        .pluck(:chain, :integer_value, :updated_at)
        .map { |row| { "scanned_#{row[0]}_block_number": row[1], "latest_scan_#{row[0]}_at": row[2] } }
        .reduce(&:merge)
    render json: current_block_nums.merge(latest_fetch_coin_price_at: CoinMarketChart.order(timestamp: :desc).first&.timestamp)
  end
end
