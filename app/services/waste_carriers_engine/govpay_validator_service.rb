# frozen_string_literal: true

module WasteCarriersEngine
  # Validates requests to record a successful or failed Govpay payment.

  # This should happen after a user attempts to make a payment on the Govpay site. They are then redirected to
  # a callback route which checks the payment status and decides how to route them onwards. This service is to
  # validate the payment status before we record that a payment has been made (or failed) and allow the user
  # to continue.
  class GovpayValidatorService
    def initialize(order, payment_uuid, govpay_status)
      @order = order
      @payment_uuid = payment_uuid
      @govpay_status = govpay_status
    end

    def valid_success?
      valid?(:success)
    end

    def valid_failure?
      valid?(:failure)
    end

    def valid_pending?
      valid?(:pending)
    end

    def valid_cancel?
      valid?(:cancel)
    end

    def valid_error?
      valid?(:error)
    end

    def self.valid_govpay_status?(response_type, status)
      @allowed_statuses ||= {
        success: %w[success],
        failure: %w[failed],
        pending: %w[created started submitted],
        cancel: %w[cancelled],
        error: %w[error]
      }.freeze
      @allowed_statuses[response_type].include?(status)
    end

    private

    def valid?(action)
      valid_order? && valid_payment_uuid? && valid_status?(action)
    end

    def valid_order?
      return true if @order.present?

      Rails.logger.error "Invalid Govpay response: Cannot find matching order"
      false
    end

    def valid_payment_uuid?
      unless @payment_uuid.present?
        Rails.logger.error "Invalid Govpay response: Missing payment uuid"
        return false
      end

      transient_registration = TransientRegistration.find_by("financeDetails.orders.payment_uuid": @payment_uuid)
      unless transient_registration.nil?
        order = transient_registration.finance_details.orders.find_by(payment_uuid: @payment_uuid)
      end

      return true if order.present?

      Rails.logger.error "Invalid Govpay response: Cannot find matching order for payment uuid #{@payment_uuid}"
      false
    end

    def valid_status?(response_type)
      return true if GovpayValidatorService.valid_govpay_status?(response_type, @govpay_status)

      Rails.logger.error "Invalid Govpay response: #{@status} is not a valid payment status for #{response_type}"
      false
    end
  end
end
