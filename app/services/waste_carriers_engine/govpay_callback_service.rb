# frozen_string_literal: true

require "rest-client"

module WasteCarriersEngine
  class GovpayCallbackService
    def initialize(payment_uuid, action)
      @payment_uuid = payment_uuid
      @action = action
    end

    def process_payment
      Rails.logger.tagged("GovpayCallbackService", "process_payment") do
        @govpay_payment_status = govpay_payment_details_service.govpay_payment_status
        @transient_registration = transient_registration_by_payment_uuid

        @order = order_by_payment_uuid

        return false unless valid_response?

        log_callback_details

        case GovpayPaymentDetailsService.payment_status(@action)
        when :success, :pending
          update_payment_data
        else
          update_order_status
        end

        true
      rescue StandardError => e
        DetailedLogger.warn "Error processing payment_uuid #{@payment_uuid}: #{e}"
        raise e
      end
    end

    private

    def valid_response?
      validator = GovpayValidatorService.new(@order, @payment_uuid, @govpay_payment_status)
      valid = validator.public_send("valid_#{GovpayPaymentDetailsService.payment_status(@action)}?")

      DetailedLogger.warn "Validating status \"#{@govpay_payment_status}\" " \
                          "for payment uuid #{@payment_uuid}, valid: #{valid}"

      valid
    end

    def update_payment_data
      DetailedLogger.warn "Updating order #{@order.id}, reference #{@order.order_code} after online payment"
      @order.update_after_online_payment
      DetailedLogger.warn "Creating payment after online payment"
      payment = Payment.new_from_online_payment(@order, user_email)
      payment.update_after_online_payment(
        govpay_status: @govpay_payment_status,
        govpay_id: @order.govpay_id
      )
      @transient_registration.finance_details.update_balance
      @transient_registration.finance_details.save!
    end

    def update_order_status
      @order.update_after_online_payment
    end

    def govpay_payment_details_service
      GovpayPaymentDetailsService.new(
        payment_uuid: @payment_uuid,
        is_moto: WasteCarriersEngine.configuration.host_is_back_office?
      )
    end

    def transient_registration_by_payment_uuid
      TransientRegistration.find_by("financeDetails.orders.payment_uuid": @payment_uuid)
    end

    def order_by_payment_uuid
      return nil unless @transient_registration&.finance_details.present?

      @transient_registration.finance_details.orders&.find_by(payment_uuid: @payment_uuid)
    end

    def user_email
      @current_user&.email || @transient_registration.contact_email
    end

    def log_callback_details
      DetailedLogger.warn "payment_uuid: #{@payment_uuid}; " \
                          "action: #{@action}; " \
                          "payment_status: #{@govpay_payment_status}, " \
                          "transient_registration id: #{@transient_registration&.id}, " \
                          "transient_registration reg_identifier: #{@transient_registration&.reg_identifier}, " \
                          "order code: #{@order&.order_code}"
    end
  end
end
