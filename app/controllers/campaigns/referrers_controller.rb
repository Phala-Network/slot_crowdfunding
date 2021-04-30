# frozen_string_literal: true

module Campaigns
  class ReferrersController < Campaigns::ApplicationController
    JS_APP_PATH = Rails.root.join("vendor", "polkadot_js_snippets")

    def update
      out =
        Dir.chdir JS_APP_PATH do
          `node verify_referrer.js --address=#{params[:address]} --referrer=#{params[:referrer]} --signature=#{params[:signature]}`
        end

      if out.blank? || out == "false"
        render status: :bad_request,
               json: {
                 status: "error",
                 error: "ADDRESS_INVALID"
               }
        return
      end

      contributor = @campaign.contributors.find_or_create_by address: params[:address]
      if contributor.referrer
        render status: :bad_request,
               json: {
                 status: "error",
                 error: "REFERRER_ALREADY_SET"
               }
        return
      end

      referrer = @campaign.contributors.find_or_create_by address: params[:referrer]
      contributor.update! referrer: referrer

      render json: {
        status: "ok"
      }
    end

    private

      def referrer_params
        params.require(%i[address referrer signature])
      end
  end
end
