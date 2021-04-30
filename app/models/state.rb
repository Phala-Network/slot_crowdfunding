# frozen_string_literal: true

class State < ApplicationRecord
  scope :visible, -> { where(visible: true) }

  class << self
    def current_block_num(chain:)
      find_or_create_by! chain: chain, key: "current_block_num" do |record|
        record.integer_value = 0
      end
    end

    def start_block_num(chain:)
      find_or_create_by! chain: chain, key: "start_block_num" do |record|
        record.integer_value = 1
      end
    end
  end
end
