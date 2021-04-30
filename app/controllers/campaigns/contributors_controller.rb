# frozen_string_literal: true

module Campaigns
  class ContributorsController < Campaigns::ApplicationController
    def index
      scoped_contributors = @campaign.contributors
      unless params[:all].present?
        scoped_contributors = scoped_contributors.where("amount > 0 OR promotion_reward_amount > 0")
      end
      unless params[:unsorted].present?
        scoped_contributors = scoped_contributors.order(amount: :desc)
      end
      if params[:referrer].present?
        referrer = @campaign.contributors.find_by! address: params[:referrer]
        scoped_contributors = scoped_contributors.where(referrer: referrer)
      end

      @pagy, @contributors = pagy(scoped_contributors, page: params[:page], items: params[:per_page])

      meta = {}
      if params[:contributor].present?
        current_contributor = @campaign.contributors.find_by! address: params[:contributor]
        meta[:rank] = current_contributor.amount > 0 ? @campaign.contributors.where("amount > ?", current_contributor.amount).count + 1 : 0
      end

      render json: {
        meta: meta,
        contributors: @contributors.map { |contributor| serialize_contributor contributor },
        pagination: serialize_pagy(@pagy)
      }
    end

    def show
      @contributor = @campaign.contributors.find_by! address: params[:id]

      render json: {
        contributor: serialize_contributor(@contributor),
        meta: serialize_contributor_meta(@contributor)
      }
    end

    private

      def serialize_contributor(contributor)
        {
          address: contributor.address,
          amount: contributor.amount.to_f.truncate(4),
          reward_amount: contributor.reward_amount.to_f.truncate(4),
          referrer: contributor.referrer&.address,
          referrals_count: contributor.referrals_count,
          promotion_reward_amount: contributor.promotion_reward_amount.to_f.truncate(4),
          calculated_reward_amount: (contributor.reward_amount + contributor.promotion_reward_amount).to_f.truncate(4)
        }
      end

      def serialize_contributor_meta(contributor)
        {
          rank: contributor.amount > 0 ? @campaign.contributors.where("amount > ?", contributor.amount).count + 1 : 0,
          latest_contributions: contributor.contributions.order(timestamp: :desc).limit(3).map do |contribution|
            {
              amount: contribution.amount.to_f.truncate(4),
              reward_amount: contribution.reward_amount.to_f.truncate(4),
              timestamp: contribution.timestamp,
              on_chain_hash: contribution.on_chain_hash
            }
          end
        }
      end
  end
end
