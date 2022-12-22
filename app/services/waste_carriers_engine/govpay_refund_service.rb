# frozen_string_literal: true

require "rest-client"
require_relative "./govpay"

module WasteCarriersEngine
  class GovpayRefundService < ::WasteCarriersEngine::BaseService
    include CanSendGovpayRequest

    def run(payment:, amount:, merchant_code: nil) # rubocop:disable Lint/UnusedMethodArgument
      return false unless payment.govpay?

      @payment = payment
      @amount = amount

      return false unless govpay_payment.refundable?(amount)
      return false if error
      return false unless refund.success?

      refund
    rescue StandardError => e
      Rails.logger.error "#{e.class} error in Govpay refund service for payment #{payment.govpay_id}, amount #{amount}"
      Airbrake.notify(e, message: "Error in Govpay refund service", govpay_id: payment.govpay_id, amount:)
      raise e
    end

    private

    attr_reader :transient_registration, :payment, :current_user, :amount

    def govpay_payment
      @govpay_payment ||=
        GovpayPaymentDetailsService.new(
          govpay_id: payment.govpay_id,
          entity: ::WasteCarriersEngine::Registration
        ).payment
    end

    def refund
      @refund ||= Govpay::Refund.new response
    end

    def error
      return @error if defined?(@error)

      @error = (Govpay::Error.new(response) if status_code.is_a?(Integer) && (400..500).include?(status_code))
    end

    def params
      {
        amount: amount,
        refund_amount_available: govpay_payment.refund.amount_available
      }
    end

    def request
      @request ||=
        send_request(
          :post, "/payments/#{payment.govpay_id}/refunds", params
        )
    end

    def response
      @response ||= JSON.parse(request)
    end

    def status_code
      request.code
    end
  end
end
