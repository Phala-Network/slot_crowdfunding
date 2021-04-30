# frozen_string_literal: true

class Contributor < ApplicationRecord
  belongs_to :campaign

  belongs_to :referrer, class_name: "Contributor", optional: true, inverse_of: :referrals, counter_cache: :referrals_count
  has_many :referrals, class_name: "Contributor", foreign_key: :referrer_id, inverse_of: :referrer, counter_cache: :referrals_count, dependent: :nullify

  has_many :contributions, dependent: :delete_all

  validates :address,
            presence: true,
            uniqueness: { scope: :campaign }

  def referrer_address
    referrer&.address
  end

  def referrer_address=(val, not_found_strategy: :raise)
    if val.nil?
      self.referrer = nil
      return
    end

    found_referrer = Contributor.find_by campaign_id: campaign_id, address: val
    if found_referrer
      self.referrer = found_referrer
    elsif not_found_strategy == :set_nil
      self.referrer = nil
    elsif not_found_strategy == :raise
      raise ActiveRecord::RecordNotFound.new(
        "Couldn't fetch #{Contributor} with address `#{val}`",
          Contributor, :address, val
        )
    end
  end
end
