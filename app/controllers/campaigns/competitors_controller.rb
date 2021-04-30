# frozen_string_literal: true

module Campaigns
  class CompetitorsController < Campaigns::ApplicationController
    def index
      @competitors = @campaign.competitors.order(raised_amount: :desc)

      render json: {
        competitors: @competitors.map { |competitor| serialize_competitor(competitor) },
        meta: {
          raised_amount: @campaign.raised_amount.to_f.truncate(4)
        }
      }
    end

    private

      def serialize_competitor(competitor)
        {
          parachain_ids: competitor.parachain_ids,
          start_block: competitor.start_block,
          end_block: competitor.end_block,
          raised_amount: competitor.raised_amount.to_f.truncate(4)
        }
      end
  end
end
