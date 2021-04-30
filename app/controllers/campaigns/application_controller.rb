# frozen_string_literal: true

module Campaigns
  class ApplicationController < ::ApplicationController
    before_action :set_campaign

    private

      def set_campaign
        @campaign = Campaign.find(params[:campaign_id])
      end
  end
end
