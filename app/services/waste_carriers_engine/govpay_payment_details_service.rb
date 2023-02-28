# frozen_string_literal: true

require "rest-client"

module WasteCarriersEngine
  class GovpayPaymentDetailsService
    include CanSendGovpayRequest

    def initialize(govpay_id: nil, is_moto: false, payment_uuid: nil,
                   entity: ::WasteCarriersEngine::TransientRegistration)
      @payment_uuid = payment_uuid
      @is_moto = is_moto
      @entity = entity
      @govpay_id = govpay_id || order.govpay_id
    end

    # Payment status in Govpay terms
    def govpay_payment_status
      status = response&.dig("state", "status") || "error"

      # Special case: If failed, check whether this was because of a cancellation
      status = "cancelled" if status == "failed" && response.dig("state", "code") == "P0030"

      status
    rescue StandardError => e
      Rails.logger.error "#{e.class} error retrieving status for payment, " \
                         "uuid #{@payment_uuid}, govpay id #{govpay_id}: #{e}"
      Airbrake.notify(e, message: "Failed to retrieve status for payment",
                         payment_uuid:,
                         govpay_id:,
                         entity:)

      raise e
    end

    def payment
      @payment ||= Govpay::Payment.new(response)
    end

    # Payment status in application terms
    def self.payment_status(status)
      {
        "created" => :pending,
        "started" => :pending,
        "submitted" => :pending,
        "cancelled" => :cancel,
        "failed" => :failure,
        nil => :error
      }.freeze[status] || status.to_sym
    end

    private

    attr_reader :payment_uuid, :entity, :govpay_id

    def response
      @response ||=
        JSON.parse(
          send_request(method: :get,
                       path: "/payments/#{govpay_id}",
                       is_moto: @is_moto,
                       params: nil)&.body
        )
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
