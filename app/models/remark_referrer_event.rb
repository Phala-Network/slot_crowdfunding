# frozen_string_literal: true

class RemarkReferrerEvent < ApplicationRecord
  validates :para_id, :who, :referrer,
            presence: true

  def process!
    return if processed?

    if who == referrer
      update! processed: true
      return
    end

    transaction do
      # Normally, it should only has one matched campaign
      campaigns = Campaign
                    .where(chain: chain, parachain_id: para_id)
                    .where("start_block <= ? AND end_block >= ?", block_num, block_num)
      if campaigns.empty?
        next
      end

      campaigns.each do |campaign|
        contributor = campaign.contributors.find_or_create_by! address: who
        next if contributor.referrer_id.present?

        referrer_contributor = campaign.contributors.find_or_create_by! address: referrer
        next if referrer_contributor.referrer_id == contributor.id

        referrer_contributor.referrals << contributor
        referrer_contributor.reload
        referrer_contributor.calculate_reward!
      end

      update! processed: true
    end
  end
end
