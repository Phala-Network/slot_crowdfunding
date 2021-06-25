# frozen_string_literal: true

class Contribution < ApplicationRecord
  belongs_to :campaign
  belongs_to :contributor
  belongs_to :event, class_name: "ContributionEvent"

  validates :event_id,
            presence: true,
            uniqueness: true

  before_validation :set_campaign_by_contributor
  after_create :accumulate_to_campaign
  after_create :accumulate_to_hourly_stats
  after_create :accumulate_to_contributor
  after_create :calculate_reward
  after_create :recalculate_contributor_reward

  private

    def set_campaign_by_contributor
      return if self.campaign_id == contributor.campaign_id

      self.campaign = contributor.campaign
    end

    def accumulate_to_campaign
      campaign.increment! :raised_amount, amount
    end

    def accumulate_to_contributor
      contributor.increment! :amount, amount
    end

    def accumulate_to_hourly_stats
      nearest_hour = timestamp.beginning_of_hour
      nearest_hour = nearest_hour - (nearest_hour.hour % 4).hour
      stat = campaign.hourly_contributions.find_or_create_by! timestamp: nearest_hour do |record|
        last_hour = campaign.hourly_contributions.order(timestamp: :desc).first
        record.amount = last_hour&.amount || 0
      end
      stat.increment! :amount, amount
    end

    EARLY_BIRD_EXPIRES_AT = Time.utc(2021, 6, 22, 12, 0, 0).freeze
    def calculate_reward
      return unless campaign.reward_strategy == "1"

      reward_coefficient = timestamp <= EARLY_BIRD_EXPIRES_AT ? 121.2 : 120
      self.reward_amount =
        if campaign.raised_amount >= campaign.cap
          0
        elsif campaign.cap - campaign.raised_amount < amount
          (campaign.cap - campaign.raised_amount) * reward_coefficient
        else
          amount * reward_coefficient
        end
      self.promotion_reward_amount = amount * 0.6

      save!
    end

    def recalculate_contributor_reward
      contributor.calculate_reward!
    end
end
