# frozen_string_literal: true

module Campaigns
  class ContributionsController < Campaigns::ApplicationController
    def index
      meta = {}
      scoped_contributions = @campaign.contributions.includes(:contributor).order(timestamp: :desc)
      if params[:contributor].present?
        contributor = @campaign.contributors.find_by! address: params[:contributor]
        scoped_contributions = scoped_contributions.where(contributor: contributor)
      elsif params[:referrer].present?
        contributor = @campaign.contributors.find_by! address: params[:referrer]
        scoped_contributions = scoped_contributions.where(contributor: contributor.referrals)

        meta[:referrals_count] = contributor.referrals.size
        meta[:promotion_reward_amount] = scoped_contributions.sum(:promotion_reward_amount).to_f.truncate(4)
      end

      @pagy, @contributions = pagy(scoped_contributions, page: params[:page], items: params[:per_page])

      render json: {
        meta: meta,
        contributions: @contributions.map { |contribution| serialize_contribution contribution },
        pagination: serialize_pagy(@pagy)
      }
    end

    private

      def serialize_contribution(contribution)
        {
          address: contribution.contributor.address,
          amount: contribution.amount.to_f.truncate(4),
          reward_amount: contribution.reward_amount.to_f.truncate(4),
          promotion_reward_amount: contribution.contributor.referrer_id.present? ? contribution.promotion_reward_amount.to_f.truncate(4) : 0,
          timestamp: contribution.timestamp,
          on_chain_hash: contribution.on_chain_hash
        }
      end
  end
end
