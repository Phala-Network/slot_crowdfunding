# frozen_string_literal: true

module Campaigns
  class AnnouncementsController < Campaigns::ApplicationController
    def index
      scoped_announcements = @campaign.announcements.where("published_at < ?", Time.zone.now).order(published_at: :desc)
      scoped_announcements =
        if params[:locale].present? && Announcement.locales.include?(params[:locale])
          scoped_announcements.where(locale: params[:locale])
        else
          scoped_announcements.where(locale: "en")
        end
      @pagy, @announcements = pagy(scoped_announcements, page: params[:page], items: params[:per_page])

      render json: {
        meta: {},
        announcements: @announcements.map { |announcement| serialize_announcement(announcement) },
        pagination: serialize_pagy(@pagy)
      }
    end

    private

      def serialize_announcement(announcement)
        {
          id: announcement.id,
          title: announcement.title,
          link: announcement.link,
          body: announcement.body,
          locale: announcement.locale,
          published_at: announcement.published_at
        }
      end
  end
end
