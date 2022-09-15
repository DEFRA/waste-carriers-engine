# frozen_string_literal: true

require "rest-client"
require_relative 'govpay'

module WasteCarriersEngine
  class GovpayRefundService < ::WasteCarriersEngine::BaseService
    include CanSendGovpayRequest

    def run(payment:, amount:, merchant_code:)
      @payment = payment
      @amount = amount

      byebug

      return false unless govpay_payment.refundable?(amount)
      return false if error
      return false unless refund.success?

      refund
    end

    private

    attr_reader :transient_registration, :payment, :current_user

    def govpay_payment
      @govpay_payment ||= GovpayPaymentDetailsService.new(govpay_id: payment.govpay_id, entity: ::WasteCarriersEngine::Registration).payment
    end

    def refund
      @refund ||= ::WasteCarriersEngine::Govpay::Refund.new response
    end

    def error
      return @error if defined?(@error)

      @error = if status_code.is_a?(Integer) && (400..500) === status_code
        Govpay::Error.new response
      end
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
          :post, "/payments/#{payment.payment_id}/refunds", params
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
