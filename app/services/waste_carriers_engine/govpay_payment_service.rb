# frozen_string_literal: true

require "rest-client"

module WasteCarriersEngine
  class GovpayPaymentService

    def initialize(transient_registration, order, current_user = nil)
      @transient_registration = transient_registration
      @order = order
      @current_user = current_user
    end

    def prepare_for_payment
      Rails.logger.tagged("GovpayPaymentService", "prepare_for_payment") do
        response = govpay_payment_response
        response_json = JSON.parse(response.body)

        govpay_payment_id = response_json["payment_id"]
        DetailedLogger.warn "payment_uuid #{@order.payment_uuid}, payment_params: #{payment_params}, " \
                            "received govpay payment id #{govpay_payment_id}"
        DetailedLogger.warn "govpay_redirect_url for response #{response}: \"#{govpay_redirect_url(response)}\""
        DetailedLogger.warn "payment_callback_url: \"#{payment_callback}\""
        DetailedLogger.warn "WCRS_MOCK_BO_GOVPAY_URL: \"#{ENV["WCRS_MOCK_BO_GOVPAY_URL"]}\""
        DetailedLogger.warn "WCRS_MOCK_FO_GOVPAY_URL: \"#{ENV["WCRS_MOCK_FO_GOVPAY_URL"]}\""
        DetailedLogger.warn "WCRS_MOCK_BO_GOVPAY_URL_INTERNAL: \"#{ENV["WCRS_MOCK_BO_GOVPAY_URL_INTERNAL"]}\""
        DetailedLogger.warn "WCRS_MOCK_FO_GOVPAY_URL_INTERNAL: \"#{ENV["WCRS_MOCK_FO_GOVPAY_URL_INTERNAL"]}\""
        DetailedLogger.warn "DefraRubyMocks.configuration.govpay_mocks_external_root_url => #{DefraRubyMocks.configuration.govpay_mocks_external_root_url}"
        DetailedLogger.warn "DefraRubyMocks.configuration.govpay_mocks_external_root_url_other => #{DefraRubyMocks.configuration.govpay_mocks_external_root_url_other}"
        DetailedLogger.warn "DefraRubyMocks.configuration.govpay_mocks_internal_root_url => #{DefraRubyMocks.configuration.govpay_mocks_internal_root_url}"
        DetailedLogger.warn "DefraRubyMocks.configuration.govpay_mocks_internal_root_url_other => #{DefraRubyMocks.configuration.govpay_mocks_internal_root_url_other}"


        WCRS_MOCK_BO_GOVPAY_URL=https://wcr-dev.aws-int.defra.cloud/fo/mocks/govpay/v1
        WCRS_MOCK_FO_GOVPAY_URL=https://wcr-admin-dev.aws-int.defra.cloud/bo/mocks/govpay/v1
        WCRS_MOCK_BO_GOVPAY_URL_INTERNAL=https://devwcr.aws-int.defra.cloud:8002/fo/mocks/govpay/v1
        WCRS_MOCK_FO_GOVPAY_URL_INTERNAL

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

    def govpay_payment_response
      DefraRubyGovpay::API.new(host_is_back_office:).send_request(
        method: :post,
        path: "/payments",
        is_moto: host_is_back_office,
        params: payment_params
      )
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
