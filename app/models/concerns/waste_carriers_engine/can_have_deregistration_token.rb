# frozen_string_literal: true

module WasteCarriersEngine
  module CanHaveDeregistrationToken
    extend ActiveSupport::Concern
    include CanGenerateAndValidateToken

    DEFAULT_TOKEN_VALIDITY_PERIOD = 7 # days

    included do
      field :deregistration_token, type: String
      field :deregistration_token_created_at, type: DateTime
    end

    def generate_deregistration_token
      generate_token(:deregistration_token, :deregistration_token_created_at)
    end

    def deregistration_token_valid?
      return false unless active?

      validity_period = ENV.fetch("WCRS_DEREGISTRATION_TOKEN_VALIDITY", 7).to_i
      token_valid?(:deregistration_token, :deregistration_token_created_at, validity_period)
    end
  end
end
