# frozen_string_literal: true

class Competitor < ApplicationRecord
  belongs_to :campaign

  serialize :parachain_ids, Array
end
