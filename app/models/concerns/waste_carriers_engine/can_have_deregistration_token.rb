# frozen_string_literal: true

module WasteCarriersEngine
  module CanHaveDeregistrationToken
    extend ActiveSupport::Concern
    include Mongoid::Document

    included do
      # This is separate to the CanHaveSecureToken token, which never expires.
      field :deregistration_token, type: String
      field :deregistration_token_created_at, type: DateTime

      def generate_deregistration_token
        self.deregistration_token_created_at = Time.zone.now
        self.deregistration_token = SecureTokenService.run
        save!

        deregistration_token
      end

      def deregistration_token_valid?
        return false unless active?

        return false unless deregistration_token.present? && deregistration_token_created_at.present?

        deregistration_token_expires_at >= Time.zone.now
      end

      private

      def deregistration_token_expires_at
        @deregistration_token_validity_period = ENV.fetch("WCRS_DEREGISTRATION_TOKEN_VALIDITY", 7).to_i
        deregistration_token_created_at + @deregistration_token_validity_period.days
      end
    end
  end
end
