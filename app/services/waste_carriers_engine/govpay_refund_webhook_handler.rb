# frozen_string_literal: true

module WasteCarriersEngine
  class GovpayRefundWebhookHandler < BaseService
    attr_reader :govpay_payment_id

    def run(webhook_body)
      @govpay_payment_id = webhook_body["resource_id"]
      refund = find_refund

      previous_status = refund&.govpay_payment_status

      result = DefraRubyGovpay::WebhookRefundService.run(
        webhook_body,
        previous_status: previous_status
      )

      result[:id]
      new_status = result[:status]

      GovpayUpdateRefundStatusService.run(refund:, new_status:)
    end

    private

    def find_refund
      payment = GovpayFindPaymentService.run(payment_id: govpay_payment_id)
      handle_payment_not_found unless payment.present?

      # Look for the refund as a sibling of the original payment
      @refund = payment.finance_details.payments.where(
        payment_type: "REFUND",
        refunded_payment_govpay_id: govpay_payment_id
      ).last
      handle_refund_not_found unless @refund.present?

      @refund
    end

    def handle_payment_not_found
      error_message = "Govpay payment not found for govpay_id #{govpay_payment_id}"
      Rails.logger.error error_message
      Airbrake.notify error_message
      raise ArgumentError, "payment not found"
    end

    def handle_refund_not_found
      error_message = "Govpay refund not found for payment with govpay_id #{govpay_payment_id}"
      Rails.logger.error error_message
      Airbrake.notify error_message
      raise ArgumentError, "refund not found"
    end
  end
end
