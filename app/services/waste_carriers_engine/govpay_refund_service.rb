# frozen_string_literal: true

require "rest-client"

module WasteCarriersEngine
  class GovpayRefundService < ::WasteCarriersEngine::BaseService
    include CanSendGovpayRequest

    def initialize(transient_registration, payment, amount, current_user)
      @transient_registration = transient_registration
      @payment = payment
      @amount = amount
      @current_user = current_user
    end

    def call
      return :cannot_refund unless payment.refundable?(amount)

    end

    private

    attr_reader :transient_registration, :payment, :current_user

    def refund
      @refund ||= Govpay::Refund.new response
    end

    def response
      @response ||=
        JSON.parse(
          send_request(
            :post, "/payments/#{payment.payment_id}/refunds", params
          )
        )
    end

    def params
      {
        amount: amount,
        refund_amount_available: payment.refund.amount_available
      }
    end

    def payment_callback_url
      host = Rails.configuration.host
      path = WasteCarriersEngine::Engine.routes.url_helpers.payment_callback_govpay_forms_path(
        token: @transient_registration.token, uuid: @order.payment_uuid
      )

      [host, path].join
    end

    def govpay_redirect_url
      @govpay_redirect_url ||= response.body.dig("_links", "next_url", "href")
    end
  end
end
