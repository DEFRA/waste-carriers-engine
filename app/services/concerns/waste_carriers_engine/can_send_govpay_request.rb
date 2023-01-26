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

      def send_request(method, path, params = nil)
        Rails.logger.info "Sending #{method} request to Govpay (#{path}), params: #{params}"

        begin
          response = RestClient::Request.execute(
            method: method,
            url: url(path),
            payload: params.present? ? params.compact.to_json : nil,
            headers: {
              "Authorization" => "Bearer #{bearer_token}",
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

      def bearer_token
        @bearer_token ||= Rails.configuration.govpay_api_token
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
end
