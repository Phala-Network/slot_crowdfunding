# frozen_string_literal: true

class Campaign < ApplicationRecord
  has_many :contributors, dependent: :destroy
  has_many :contributions, dependent: :delete_all

  enum chain: {
    kusama: "kusama",
    polkadot: "polkadot",
    rococo: "rococo",
    dev: "dev"
  }

  enum status: {
    created: "created",
    ongoing: "ongoing",
    completed: "completed"
  }

  validates :name,
            presence: true

  validates :chain,
            presence: true,
            inclusion: chains.values

  validates :status,
            presence: true,
            inclusion: statuses.values

  validates :parachain_id,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 1000
            }

  validates :cap,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than: 0
            }

  validates :start_block,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than: 0
            }
  validates :end_block,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than: :start_block
            }

  # default_value_for :status, "created", allow_nil: false
end
