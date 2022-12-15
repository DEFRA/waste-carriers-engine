# frozen_string_literal: true

module WasteCarriersEngine
  module CanSendWorldpayRequest
    extend ActiveSupport::Concern

    # rubocop:disable Metrics/BlockLength
    included do
      private

      def send_request(xml)
        Rails.logger.debug "Sending initial request to WorldPay"

        response = nil
        begin
          response = RestClient::Request.execute(
            method: :post,
            url: url,
            payload: xml,
            headers: {
              "Authorization" => authorization
            }
          )

          Rails.logger.debug "Received response from WorldPay"
        rescue StandardError => e
          Rails.logger.error("Error sending request to worldpay: #{e}")
          Airbrake.notify(e, message: "Error on WorldPay request")
        end

        response
      end

      def url
        @_url ||= Rails.configuration.worldpay_url
      end

      def authorization
        @_authorization ||= "Basic #{Base64.encode64("#{username}:#{password}")}"
      end

      def username
        @_username ||= Rails.configuration.worldpay_username
      end

      def password
        @_password ||= Rails.configuration.worldpay_password
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
end
