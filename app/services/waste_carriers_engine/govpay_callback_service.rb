# frozen_string_literal: true

require "rest-client"

module WasteCarriersEngine
  class GovpayCallbackService

    def initialize(payment_uuid)
      @payment_uuid = payment_uuid
      @transient_registration = transient_registration_by_payment_uuid
      @order = order_by_payment_uuid
    end

    def run
      @govpay_payment_status = GovpayPaymentDetailsService.new(@payment_uuid).govpay_payment_status

      @response_type = GovpayPaymentDetailsService.response_type(@govpay_payment_status)
      return :error unless govpay_response_validator(@govpay_payment_status).send("valid_#{@response_type}?".to_sym)

      case @response_type
      when :success, :pending
        update_payment_data
      else
        unsuccessful_payment
      end

      @response_type
    end

    private

    def transient_registration_by_payment_uuid
      reg = TransientRegistration.find_by("financeDetails.orders.payment_uuid": @payment_uuid)
      raise ArgumentError, "Transient registration not found for payment uuid #{@payment_uuid}" unless reg

      reg
    end

    def order_by_payment_uuid
      order = @transient_registration.finance_details.orders.find_by(payment_uuid: @payment_uuid)
      raise ArgumentError, "Order not found for payment uuid #{@payment_uuid}" unless order

      order
    end

    def unsuccessful_payment
      @order.update_after_online_payment(@response_type)
    end

    def update_payment_data
      @order.update_after_online_payment(@response_type)
      payment = Payment.new_from_online_payment(@order, user_email)
      payment.update_after_online_payment(govpay_status: @response_type)

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
