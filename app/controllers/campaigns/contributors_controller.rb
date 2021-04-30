# frozen_string_literal: true

module Campaigns
  class ContributorsController < Campaigns::ApplicationController
    def index
      scoped_contributors = @campaign.contributors.where("amount > 0").order(amount: :desc)
      @pagy, @contributors = pagy(scoped_contributors, page: params[:page], items: params[:per_page])

      render json: {
        meta: {},
        contributors: @contributors.map { |contributor| serialize_contributor contributor },
        pagination: serialize_pagy(@pagy)
      }
    end

    def show
      @contributor = @campaign.contributors.find_by! address: params[:id]

      render json: {
        meta: {},
        contributor: serialize_contributor(@contributor)
      }
    end

    private

      def serialize_contributor(contributor)
        {
          address: contributor.address,
          amount: contributor.amount,
          reward_amount: contributor.reward_amount,
          referrals_count: contributor.referrals_count,
          referral_reward_amount: contributor.referral_reward_amount
        }
      end
  end
end
