# frozen_string_literal: true

module WasteCarriersEngine
  module CanSendGovpayRequest
    extend ActiveSupport::Concern

    # rubocop:disable Metrics/BlockLength
    included do
      private

      def send_request(method, path, params = nil)
        response = nil

        begin
          response = RestClient::Request.execute(
            method: method,
            url: url(path),
            payload: params.present? ? params.to_json : nil,
            headers: {
              "Authorization" => "Bearer #{bearer_token}",
              "Content-Type" => "application/json"
            }
          )
        rescue RestClient::ExceptionWithResponse => e
          Rails.logger.debug "RestClient received response: #{e}"
          response = err.response
        rescue StandardError => e
          Rails.logger.error("Error sending request to govpay: #{e}")
          Airbrake.notify(e, message: "Error on govpay request")
        end

        response
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
