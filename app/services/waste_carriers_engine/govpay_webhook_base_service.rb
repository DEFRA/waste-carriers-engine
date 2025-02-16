# frozen_string_literal: true

module WasteCarriersEngine
  class GovpayWebhookBaseService < BaseService
    class InvalidGovpayStatusTransition < StandardError; end

    attr_accessor :webhook_body, :previous_status

    # ovverride this in subclasses
    VALID_STATUS_TRANSITIONS = {}.freeze

    def run(webhook_body)
      Rails.logger.tagged("GovpayWebhookBaseService") do
        @webhook_body = webhook_body

        validate_webhook_body

        @previous_status = wcr_payment.govpay_payment_status
        if webhook_payment_or_refund_status == @previous_status
          Rails.logger.warn "Status \"#{@previous_status}\" unchanged in #{payment_or_refund_str} webhook update " \
                            "for #{log_webhook_context}"
        else
          validate_status_transition

          update_payment_or_refund_status
        end
      end
    end

    private

    def validate_status_transition
      return if self.class::VALID_STATUS_TRANSITIONS[previous_status]&.include?(webhook_payment_or_refund_status)

      raise InvalidGovpayStatusTransition, "Invalid #{payment_or_refund_str} status transition " \
                                           "from #{previous_status} to #{webhook_payment_or_refund_status} " \
                                           "for #{log_webhook_context}"
    end

    def update_payment_or_refund_status
      # :nocov:
      raise NotImplementedError
      # :nocov:
    end

    def wcr_payment
      @wcr_payment ||= find_wcr_payment
    end

    # Because payments are embedded in finance_details, we can't search directly on the payments collection so we:
    # 1. find the registration which contains a payment with this payment id
    # 2. within that registration, find which payment has that payment id

    def registration
      @registration ||= find_registration
    end

    def find_registration
      result = Registration.find_by("finance_details.payments.govpay_id": webhook_payment_or_refund_id)
      if result.blank?
        raise ArgumentError, "Registration not found for webhook payment_id #{webhook_payment_or_refund_id}"
      end

      result
    end

    def find_wcr_payment
      registration.finance_details
                  .payments
                  .find_by(govpay_id: webhook_payment_or_refund_id)
    rescue Mongoid::Errors::DocumentNotFound
      raise ArgumentError, "Payment not found for webhook payment_id #{webhook_payment_or_refund_id}"
    end

    # the following methods differ for refunds vs card payments
    def log_webhook_context
      # :nocov:
      raise NotImplementedError
      # :nocov:
    end

    def payment_or_refund_str
      # :nocov:
      raise NotImplementedError
      # :nocov:
    end

    def validate_webhook_body
      # :nocov:
      raise NotImplementedError
      # :nocov:
    end

    def webhook_payment_or_refund_id
      # :nocov:
      raise NotImplementedError
      # :nocov:
    end

    def webhook_payment_or_refund_status
      # :nocov:
      raise NotImplementedError
      # :nocov:
    end
  end
end
