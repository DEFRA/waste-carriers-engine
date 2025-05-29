# frozen_string_literal: true

require "rest-client"

module WasteCarriersEngine
  class GovpayPaymentService

    def initialize(transient_registration, order, current_user = nil)
      Rails.logger.warn ">>>> GovpayPaymentService init"
      Rails.logger.warn ">>>> GovpayPaymentService init: TR #{transient_registration}"
      Rails.logger.warn ">>>> GovpayPaymentService init: order #{order}"

      @transient_registration = transient_registration
      @order = order
      @current_user = current_user
    end

    def prepare_for_payment
      Rails.logger.warn ">>>> GovpayPaymentService prepare_for_payment: in"
      Rails.logger.tagged("GovpayPaymentService", "prepare_for_payment") do
        Rails.logger.warn ">>>> GovpayPaymentService prepare_for_payment: after tagged"
        response = govpay_payment_response
        Rails.logger.warn ">>>> GovpayPaymentService prepare_for_payment: response: #{response}"
        response_json = JSON.parse(response.body)
        Rails.logger.warn ">>>> GovpayPaymentService prepare_for_payment: response_json: #{response_json}"

        govpay_payment_id = response_json["payment_id"]
        DetailedLogger.warn "payment_uuid #{@order.payment_uuid}, payment_params: #{payment_params}, " \
                            "received govpay payment id #{govpay_payment_id}"

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
      rescue StandardError => e
        DetailedLogger.error("prepare_for_payment error: #{e}")
        :error
      end
    end

    def payment_callback_url
      WasteCarriersEngine::DefraRubyGovpayHelper.govpay_callback_url(@transient_registration, @order)
    end

    def govpay_redirect_url(response)
      JSON.parse(response.body).dig("_links", "next_url", "href")
    end

    private

    def govpay_payment_response
      Rails.logger.warn ">>>> GovpayPaymentService govpay_payment_response: IN, calling DefraRubyGovpay::API.new(host_is_back_office:).send_request..."


      
      DefraRubyGovpay::API.new(host_is_back_office:).send_request(
        method: :post,
        path: "/payments",
        is_moto: host_is_back_office,
        params: payment_params
      )
    rescue StandardError => e
      Rails.logger.error "++++ ERROR: #{e}\n#{e.backtrace}"
    end

    def host_is_back_office
      @host_is_back_office ||= WasteCarriersEngine.configuration.host_is_back_office?
    end

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
