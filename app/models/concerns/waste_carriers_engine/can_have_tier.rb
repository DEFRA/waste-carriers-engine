# frozen_string_literal: true

module WasteCarriersEngine
  module CanHaveTier
    extend ActiveSupport::Concern
    include Mongoid::Document

    TIERS = [
      UPPER_TIER = "UPPER",
      LOWER_TIER = "LOWER"
    ].freeze

    included do
      field :tier, type: String

      def upper_tier?
        tier == UPPER_TIER
      end

      def lower_tier?
        tier == LOWER_TIER
      end
    end
  end
end
