# frozen_string_literal: true

module WasteCarriersEngine
  module CanAddDebugLogging
    extend ActiveSupport::Concern

    # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def log_transient_registration_details(description, transient_registration)
      return unless FeatureToggle.active?(:additional_debug_logging)

      error = if transient_registration.nil?
                StandardError.new("#{description}: transient_registration is nil")
              else
                StandardError.new(
                  "#{description}: " \
                  "type: #{transient_registration.class}, " \
                  "reg_identifier #{transient_registration.reg_identifier}, " \
                  "from_magic_link: #{from_magic_link(transient_registration)}, " \
                  "workflow_state: #{transient_registration.workflow_state}, " \
                  "workflow_history: #{transient_registration.workflow_history}, " \
                  "tier: #{transient_registration.tier}, " \
                  "account_email: #{transient_registration.account_email}, " \
                  "expires_on: #{transient_registration.expires_on}, " \
                  "renew_token: #{renew_token(transient_registration)}, " \
                  "metaData.route: #{transient_registration.metaData.route}, " \
                  "created_at: #{transient_registration.created_at}, " \
                  "orders: #{transient_registration.finance_details&.orders}, " \
                  "payments: #{transient_registration.finance_details&.payments}"
                )
              end
      Airbrake.notify(error, reg_identifier: transient_registration.reg_identifier) if defined?(Airbrake)
      Rails.logger.warn error

    # Handle any exceptions which arise while logging
    rescue StandardError => e
      Airbrake.notify(e, reg_identifier: transient_registration.reg_identifier) if defined?(Airbrake)
      Rails.logger.warn "Error writing transient registration details to the log: #{e}"
    end
    # rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    private

    def from_magic_link(transient_registration)
      return "N/A" unless transient_registration.is_a?(RenewingRegistration)

      transient_registration.from_magic_link ? "true" : "false"
    end

    def renew_token(transient_registration)
      return "N/A" unless transient_registration.registration.present?

      transient_registration.registration.renew_token
    rescue NotImplementedError
      "N/A"
    end
  end
end
