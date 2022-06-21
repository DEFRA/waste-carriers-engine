# frozen_string_literal: true

require "rest-client"

module WasteCarriersEngine
  class GovpayPaymentDetailsService
    include CanSendGovpayRequest

    def initialize(payment_uuid)
      # Because orders are embedded in finance_details, we can't search directly on orders so we need to:
      # 1. find the transient_registration which contains the order with this payment_uuid
      # 2. within that transient_registration, find which order has that payment_uuid
      transient_registration = TransientRegistration.find_by("financeDetails.orders.payment_uuid": payment_uuid)
      @order = transient_registration.finance_details.orders.find_by(payment_uuid: payment_uuid)
    rescue StandardError
      raise ArgumentError, "Order not found for payment uuid \"#{payment_uuid}\""
    end

    # Payment status in Govpay terms
    def govpay_payment_status
      response = send_request(:get, "/payments/#{@order.govpay_id}")
      response_json = JSON.parse(response.body)

      status = response_json&.dig("state", "status") || "error"

      # Special case: If failed, check whether this was because of a cancellation
      status = "cancelled" if status == "failed" && response_json.dig("state", "code") == "P0030"

      status
    rescue StandardError => e
      Rails.logger.error "Failed to retrieve payment status: #{e}"
      "error"
    end

    # Payment status in application terms
    def self.response_type(status)
      {
        "created" => :pending,
        "started" => :pending,
        "submitted" => :pending,
        "cancelled" => :cancel,
        "failed" => :failure,
        nil => :error
      }.freeze[status] || status.to_sym
    end
  end
end
