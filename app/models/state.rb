# frozen_string_literal: true

class State < ApplicationRecord
  scope :visible, -> { where(visible: true) }

  class << self
    def current_block_num(chain:)
      find_or_create_by! chain: chain.to_s.downcase, key: "current_block_num" do |record|
        record.integer_value = 0
      end
    end

    def start_block_num(chain:)
      find_or_create_by! chain: chain, key: "start_block_num" do |record|
        record.integer_value = 1
      end
    end

    # https://www.stakingrewards.com/earn/kusama
    SUPPORT_SYMBOLS = %w[PHA DOT KSM].map(&:downcase)

    def coin_stake_participating_rate(symbol:)
      symbol = symbol.downcase
      raise ArgumentError, "Unsupported symbol `#{symbol}`" unless SUPPORT_SYMBOLS.include? symbol

      find_or_create_by! key: "coin.#{symbol}.stake_participating_rate" do |record|
        record.decimal_value = 0
      end
    end

    def coin_stake_apr(symbol:)
      symbol = symbol.downcase
      raise ArgumentError, "Unsupported symbol `#{symbol}`" unless SUPPORT_SYMBOLS.include? symbol

      find_or_create_by! key: "coin.#{symbol}.stake_apr" do |record|
        record.decimal_value = 0
      end
    end
  end
end
