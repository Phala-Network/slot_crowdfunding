# frozen_string_literal: true

class Contribution < ApplicationRecord
  belongs_to :campaign
  belongs_to :contributor

  before_validation :set_campaign_by_contributor
  before_create :calculate_reward
  after_create :accumulate_to_contributor

  private

    def set_campaign_by_contributor
      return if self.campaign_id == contributor.campaign_id

      self.campaign = contributor.campaign
    end

    def calculate_reward
      # TODO:
      self.reward_amount = 0
      self.reward_amount_for_referrer = 0
    end

    def accumulate_to_contributor
      contributor.increment :amount, amount
      contributor.increment :reward_amount, reward_amount
      contributor.save!

      referrer = contributor.referrer
      if referrer
        referrer.increment :referral_reward_amount, reward_amount_for_referrer
        referrer.save!
      end
    end
end
