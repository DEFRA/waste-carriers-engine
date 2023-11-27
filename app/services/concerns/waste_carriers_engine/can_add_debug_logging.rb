# frozen_string_literal: true

module WasteCarriersEngine
  module CanAddDebugLogging
    extend ActiveSupport::Concern

    # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/AbcSize
    def log_transient_registration_details(description, exception, transient_registration)
      return unless FeatureToggle.active?(:additional_debug_logging)

      details = { backtrace: exception&.backtrace }
      if transient_registration.nil?
        details.merge!({ transient_registration: nil })
      else
        details.merge!({ type: transient_registration.class.to_s,
                         reg_identifier: transient_registration.reg_identifier,
                         from_magic_link: from_magic_link(transient_registration),
                         workflow_state: transient_registration.workflow_state,
                         workflow_history: transient_registration.workflow_history.to_s,
                         tier: transient_registration.tier,
                         expires_on: transient_registration.expires_on,
                         renew_token: renew_token(transient_registration),
                         "metaData.route": transient_registration.metaData&.route,
                         created_at: transient_registration.created_at,
                         orders: transient_registration.finance_details&.orders.to_s,
                         payments: transient_registration.finance_details&.payments.to_s })
      end
      Airbrake.notify(StandardError.new(description), details)
      Rails.logger.warn "#{description}: #{details}"

    # Handle any exceptions which arise while logging
    rescue StandardError => e
      # Allow for the possibility that Airbrake.notify might raise an exception
      begin
        Airbrake.notify(e, reg_identifier: transient_registration&.reg_identifier)
      rescue StandardError
        Rails.logger.warn "Message not sent to Airbrake due to exception: #{e}"
      ensure
        Rails.logger.warn "Error writing debugging information for transient registration " \
                          "#{transient_registration&.reg_identifier} to the log: #{e}"
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/AbcSize

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
