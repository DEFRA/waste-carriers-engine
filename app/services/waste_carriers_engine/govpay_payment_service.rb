# frozen_string_literal: true

require "rest-client"

module WasteCarriersEngine
  class GovpayPaymentService
    include CanSendGovpayRequest

    def initialize(transient_registration, order, current_user)
      @transient_registration = transient_registration
      @order = order
      @current_user = current_user
    end

    def prepare_for_payment
      response = send_request(:post, "/payments", payment_params)
      response_json = JSON.parse(response.body)

      govpay_payment_id = response_json["payment_id"]
      if govpay_payment_id.present?
        @order.govpay_id = govpay_payment_id
        @order.save!
        {
          payment: nil, # @payment,
          url: govpay_redirect_url(response)
        }
      else
        :error
      end
    rescue StandardError
      # The error will have been logged by CanSendGovPayRequest, just return an error response here
      :error
    end

    def payment_callback_url
      host = Rails.configuration.host
      path = WasteCarriersEngine::Engine.routes.url_helpers.payment_callback_govpay_forms_path(
        token: @transient_registration.token, uuid: @order.payment_uuid
      )

      [host, path].join
    end

    def govpay_redirect_url(response)
      JSON.parse(response.body).dig("_links", "next_url", "href")
    end

    private

    def payment_params
      {
        amount: @order.total_amount,
        return_url: payment_callback_url,
        reference: @order.order_code,
        description: "Your Waste Carrier Registration #{@transient_registration.reg_identifier}",
        moto: WasteCarriersEngine.configuration.host_is_back_office?
      }
    end
  end
end
