# frozen_string_literal: true

class ApplicationController < ActionController::API
  include Pagy::Backend

  private

    def serialize_pagy(pagy)
      {
        current_page: pagy.page,
        total_page: pagy.pages,
        total_count: pagy.count,
        per_page: pagy.items
      }
    end
end
