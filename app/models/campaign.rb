# frozen_string_literal: true

class Campaign < ApplicationRecord
  has_many :contributors, dependent: :destroy
  has_many :contributions, dependent: :delete_all
  has_many :hourly_contributions, dependent: :delete_all

  has_many :competitors, dependent: :delete_all

  has_many :announcements, dependent: :delete_all
  has_many :milestones, dependent: :delete_all

  enum chain: {
    kusama: "kusama",
    polkadot: "polkadot",
    rococo: "rococo",
    dev: "dev"
  }

  validates :name,
            presence: true

  validates :chain,
            presence: true,
            inclusion: chains.values

  validates :parachain_id,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 1000
            }

  validates :cap,
            presence: true,
            numericality: {
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

  def export_contributions
    arr = []

    contributions.order(timestamp: :asc).includes(:contributor).find_each do |c|
      arr << [
        c.contributor.address,
        c.contributor.referrer_id.present? ? 1 : 0,
        c.on_chain_hash,
        c.timestamp,
        c.amount,
        c.reward_amount,
        c.contributor.referrer_id.present? ? c.promotion_reward_amount : 0
      ]
    end

    arr
  end

  def export_contributors
    arr = []

    contributors.order(amount: :desc).where("amount > 0 OR promotion_reward_amount > 0").find_each do |c|
      arr << [
        c.address,
        c.referrer_id.present? ? 1 : 0,
        c.amount.to_f.truncate(4),
        (c.reward_amount + c.promotion_reward_amount).to_f.truncate(4)
      ]
    end

    arr
  end
end
