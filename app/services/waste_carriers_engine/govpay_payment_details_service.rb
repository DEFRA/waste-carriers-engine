# frozen_string_literal: true

require "rest-client"

module WasteCarriersEngine
  class GovpayPaymentDetailsService

    def initialize(govpay_id: nil, is_moto: false, payment_uuid: nil,
                   entity: ::WasteCarriersEngine::TransientRegistration)
      @payment_uuid = payment_uuid
      @is_moto = is_moto
      @entity = entity
      @govpay_id = govpay_id || order.govpay_id
    end

    # Payment status in Govpay terms
    def govpay_payment_status
      Rails.logger.tagged("GovpayPaymentDetailsService", "govpay_payment_status") do
        status = response&.dig("state", "status") || "error"

        # Special case: If failed, check whether this was because of a cancellation
        status = Payment::STATUS_CANCELLED if payment_cancelled(status, response)

        DetailedLogger.warn "Handling response #{response}; " \
                            "got status #{status} for payment_uuid #{@payment_uuid}}"

        status
      rescue StandardError => e
        Rails.logger.error "#{e.class} error retrieving status for payment, " \
                           "uuid #{@payment_uuid}, govpay id #{govpay_id}: #{e}"
        Airbrake.notify(e, message: e.message,
                           payment_uuid:,
                           govpay_id:,
                           entity:)

        raise e
      end
    end

    def payment
      @payment ||= DefraRubyGovpay::Payment.new(response)
    end

    # Payment status in application terms
    def self.payment_status(status)
      {
        Payment::STATUS_CREATED => :pending,
        Payment::STATUS_STARTED => :pending,
        Payment::STATUS_SUBMITTED => :pending,
        Payment::STATUS_CANCELLED => :cancel,
        Payment::STATUS_FAILED => :failure,
        nil => :error
      }.freeze[status] || status.to_sym
    end

    private

    attr_reader :payment_uuid, :entity, :govpay_id

    def defra_ruby_govpay_api
      @defra_ruby_govpay_api ||= DefraRubyGovpay::API.new(
        host_is_back_office: WasteCarriersEngine.configuration.host_is_back_office?
      )
    end

    def response
      @response ||=
        JSON.parse(
          defra_ruby_govpay_api.send_request(method: :get,
                                             path: "/payments/#{govpay_id}",
                                             is_moto: @is_moto,
                                             params: nil)&.body
        )
    end

    def payment_cancelled(status, response)
      status == Payment::STATUS_FAILED && response.dig("state", "code") == "P0030"
    end

    # Because orders are embedded in finance_details, we can't search directly on orders so we need to:
    # 1. find the transient_registration which contains the order with this payment_uuid
    # 2. within that transient_registration, find which order has that payment_uuid
    def order
      entity
        .find_by("financeDetails.orders.payment_uuid": payment_uuid)
        .finance_details
        .orders
        .find_by(payment_uuid: payment_uuid)
    rescue StandardError => e
      Airbrake.notify(e, message: "Order not found for payment uuid", payment_uuid:)
      raise ArgumentError, "Order not found for payment uuid \"#{payment_uuid}\": #{e}"
    end
  end
end
