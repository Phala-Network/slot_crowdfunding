# frozen_string_literal: true

module Campaigns
  class ContributionsController < Campaigns::ApplicationController
    def index
      meta = {}
      scoped_contributions = @campaign.contributions.includes(:contributor).order(created_at: :desc)
      if params[:contributor].present?
        contributor = @campaign.contributors.find_by! address: params[:contributor]
        scoped_contributions = scoped_contributions.where(contributor: contributor)
      elsif params[:referrer].present?
        contributor = @campaign.contributors.find_by! address: params[:referrer]
        scoped_contributions = scoped_contributions.where(contributor: contributor.referrals)

        meta[:referrals_count] = contributor.referrals.size
        meta[:reward_amount_for_referrer] = scoped_contributions.sum(:reward_amount_for_referrer)
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
          amount: contribution.amount,
          reward_amount: contribution.reward_amount,
          reward_amount_for_referrer: contribution.reward_amount_for_referrer,
          created_at: contribution.created_at
        }
      end
  end
end
