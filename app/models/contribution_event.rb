# frozen_string_literal: true

class ContributionEvent < ApplicationRecord
  def process!
    return if processed?

    transaction do
      Campaign
        .where(chain: chain, parachain_id: fund_index)
        .where("start_block <= ? AND end_block >= ?", block_num, block_num)
        .each do |campaign|
          # Normally, it should only has one matched campaign
          contributor = campaign.contributors.find_or_create_by! address: who
          contributor.contributions.create! amount: amount
        end

      update! processed: true
    end
  end
end
