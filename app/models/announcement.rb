# frozen_string_literal: true

class Announcement < ApplicationRecord
  belongs_to :campaign

  enum locale: {
    en: "en",
    zh: "zh"
  }

  validates :locale,
            presence: true
end
