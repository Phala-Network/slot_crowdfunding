# frozen_string_literal: true

class ContributionEvent < ApplicationRecord
  validates :fund_index, :who, :amount,
            presence: true

  def process!
    return if processed?

    transaction do
      # Normally, it should only has one matched campaign
      campaigns = Campaign
                    .where(chain: chain, parachain_id: fund_index)
                    .where("start_block <= ? AND end_block >= ?", block_num, block_num)
      if campaigns.empty?
        next
      end

      campaigns.each do |campaign|
        contributor = campaign.contributors.find_or_create_by! address: who
        contributor.contributions.create! amount: amount, timestamp: timestamp, on_chain_hash: on_chain_hash, event: self
      end

      update! processed: true
    end
  end
end
