# frozen_string_literal: true

require "rest-client"

module WasteCarriersEngine
  class GovpayCallbackService

    def initialize(payment_uuid)
      @payment_uuid = payment_uuid
      @payment_status = GovpayPaymentDetailsService.new(payment_uuid: @payment_uuid).govpay_payment_status
      @transient_registration = transient_registration_by_payment_uuid
      @order = order_by_payment_uuid
    end

    def valid_success?
      return false unless govpay_response_validator("success").valid_success?

      update_payment_data

      true
    end

    def valid_failure?
      valid_unsuccessful_payment?(:valid_failure?)
    end

    def valid_pending?
      valid_unsuccessful_payment?(:valid_pending?)
    end

    def valid_cancel?
      valid_unsuccessful_payment?(:valid_cancel?)
    end

    def valid_error?
      valid_unsuccessful_payment?(:valid_error?)
    end

    private

    def transient_registration_by_payment_uuid
      TransientRegistration.find_by("financeDetails.orders.payment_uuid": @payment_uuid)
    end

    def order_by_payment_uuid
      @transient_registration.finance_details.orders.find_by(payment_uuid: @payment_uuid)
    end

    def valid_unsuccessful_payment?(validation_method)
      return false unless govpay_response_validator(@payment_status).public_send(validation_method)

      @order.update_after_online_payment(@payment_status)
      true
    end

    def update_payment_data
      @order.update_after_online_payment("success")
      payment = Payment.new_from_online_payment(@order, user_email)
      payment.update_after_online_payment(govpay_status: "success", govpay_id: @order.govpay_id)

      @transient_registration.finance_details.update_balance
      @transient_registration.finance_details.save!
    end

    def govpay_response_validator(govpay_status)
      GovpayValidatorService.new(@order, @payment_uuid, govpay_status)
    end

    def user_email
      @current_user&.email || @transient_registration.contact_email
    end
  end
end
