# frozen_string_literal: true

module WasteCarriersEngine
  class GovpayWebhookPaymentService < BaseService
    class InvalidGovpayStatusTransition < StandardError; end

    attr_accessor :webhook_body, :previous_status, :registration

    VALID_STATUS_TRANSITIONS = {
      "created" => %w[started submitted success failed cancelled error],
      "started" => %w[submitted success failed cancelled error],
      "submitted" => %w[success failed cancelled error],
      "success" => %w[],
      "failed" => %w[],
      "cancelled" => %w[],
      "error" => %w[]
    }.freeze

    def run(webhook_body)
      @webhook_body = webhook_body

      raise ArgumentError, "Invalid webhook type #{webhook_resource_type}" unless webhook_resource_type == "payment"
      raise ArgumentError, "Webhook body missing payment status: #{webhook_body}" if webhook_payment_status.blank?

      @previous_status = wcr_payment.govpay_payment_status
      if webhook_payment_status == @previous_status
        Rails.logger.warn "Status \"#{@previous_status}\" unchanged in webhook update for " \
                          "payment #{webhook_payment_id}, registration #{@registration.reg_identifier}"
      else
        validate_status_transition

        update_payment_status
      end
    end

    private

    def validate_status_transition
      unless VALID_STATUS_TRANSITIONS[previous_status]&.include?(webhook_payment_status)
        raise InvalidGovpayStatusTransition, "Invalid status transition from #{previous_status} " \
                                             "to #{webhook_payment_status} for payment #{webhook_payment_id}, " \
                                             "registration #{@registration.regIdentifier}"
      end

      true
    end

    def update_payment_status
      wcr_payment.update(govpay_payment_status: webhook_payment_status)

      Rails.logger.info "Updated status for payment #{webhook_payment_id}, " \
                        "registration #{@registration.regIdentifier} " \
                        "from #{previous_status} to #{webhook_payment_status}"
    end

    def webhook_resource_type
      @webhook_resource_type ||= webhook_body["resource_type"]
    end

    def webhook_payment_status
      @webhook_payment_status ||= webhook_body.dig("resource", "state", "status")
    end

    def webhook_payment_id
      @webhook_payment_id ||= webhook_body.dig("resource", "payment_id")
    end

    def wcr_payment
      @wcr_payment ||= find_wcr_payment
    end

    def find_wcr_payment
      # Because payments are embedded in finance_details, we can't search directly on the payments collection so we:
      # 1. find the registration which contains a payment with this payment id
      # 2. within that registration, find which payment has that payment id

      @registration = Registration.find_by("finance_details.payments.govpay_id": webhook_payment_id)
      raise ArgumentError, "Payment not found for webhook payment_id #{webhook_payment_id}" if @registration.blank?

      @registration.finance_details
                   .payments
                   .find_by(govpay_id: webhook_payment_id)
    rescue Mongoid::Errors::DocumentNotFound
      raise ArgumentError, "Payment not found for webhook payment_id #{webhook_payment_id}"
    end
  end
end
