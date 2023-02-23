# frozen_string_literal: true

module WasteCarriersEngine

  class GovpayApiError < StandardError
    def initialize(msg = "Govpay API error")
      super
    end
  end

  module CanSendGovpayRequest
    extend ActiveSupport::Concern

    # rubocop:disable Metrics/BlockLength
    included do
      private

      def send_request(method:, path:, params: nil, override_api_token: false)
        Rails.logger.info "Sending #{method} request to Govpay (#{path}), params: #{params}"

        begin
          response = RestClient::Request.execute(
            method: method,
            url: url(path),
            payload: params.present? ? params.compact.to_json : nil,
            headers: {
              "Authorization" => "Bearer #{bearer_token(override_api_token)}",
              "Content-Type" => "application/json"
            }
          )

          Rails.logger.info "Received response from Govpay: #{response}"

          response
        rescue StandardError => e
          Rails.logger.error("Error sending request to govpay (#{method} #{path}, params: #{params}): #{e}")
          Airbrake.notify(e, message: "Error sending govpay request", method:, path:, params:)
          raise GovpayApiError
        end
      end

      def url(path)
        "#{Rails.configuration.govpay_url}#{path}"
      end

      # Allow the back office to use the "front office" Govpay API token for non-MOTO payment actions
      def bearer_token(override_api_token)
        is_back_office = WasteCarriersEngine.configuration.host_is_back_office?
        back_office_token = Rails.configuration.govpay_back_office_api_token
        front_office_token = Rails.configuration.govpay_front_office_api_token

        if override_api_token
          is_back_office ? front_office_token : back_office_token
        else
          is_back_office ? back_office_token : front_office_token
        end
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
end
