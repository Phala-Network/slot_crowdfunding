# frozen_string_literal: true

class CoinMarketChartsController < ApplicationController
  LIMIT = 24 * 14 # Hourly by default with 14 days
  SUPPORT_SYMBOLS = %w[PHA DOT KSM]

  def show
    symbol = params[:id]&.upcase
    unless SUPPORT_SYMBOLS.include? symbol
      render status: :not_found
      return
    end

    chart_data = CoinMarketChart.where(symbol: symbol).order(timestamp: :asc).limit(LIMIT).pluck(:timestamp, :price).map { |i| [i[0].beginning_of_hour, i[1].to_f] }.uniq(&:first)

    render json: {
      symbol: symbol,
      price: chart_data.last ? chart_data.last[1] : 0.0,
      last_updated_at: chart_data.last ? chart_data.last[0] : nil,
      # https://www.stakingrewards.com/earn/kusama
      stake_participating_rate: State.coin_stake_participating_rate(symbol: symbol).decimal_value.to_f,
      stake_apr: State.coin_stake_apr(symbol: symbol).decimal_value.to_f,
      data: chart_data
    }
  end
end
