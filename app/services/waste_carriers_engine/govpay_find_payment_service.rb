# frozen_string_literal: true

module WasteCarriersEngine
  class GovpayFindPaymentService < WasteCarriersEngine::BaseService
    def run(payment_id:)
      Rails.logger.tagged("GovpayFindPaymentService") do
        @last_error = nil

        payment = find_payment_in_registration(payment_id) || find_payment_in_transient_registration(payment_id)

        payment || handle_payment_not_found(payment_id)
      end
    end

    private

    # Because payments are embedded in finance_details, they don't have their own
    # collection so we can't search for them directly. We need to:
    # 1. find the registration / transient registration which contains the payment with this govpay_id
    # 2. within that registration, find which payment has that govpay_id
    def find_payment_in_registration(payment_id)
      WasteCarriersEngine::Registration
        .find_by("financeDetails.payments.govpay_id": payment_id)
        .finance_details
        .payments
        .find_by(govpay_id: payment_id)
    rescue Mongoid::Errors::DocumentNotFound, NoMethodError => e
      @last_error = e
      nil
    end

    def find_payment_in_transient_registration(payment_id)
      WasteCarriersEngine::TransientRegistration
        .find_by("financeDetails.payments.govpay_id": payment_id)
        .finance_details
        .payments
        .find_by(govpay_id: payment_id)
    rescue Mongoid::Errors::DocumentNotFound, NoMethodError => e
      @last_error = e
      nil
    end

    def handle_payment_not_found(payment_id)
      Rails.logger.error "Govpay payment not found for govpay_id #{payment_id}"
      Airbrake.notify(@last_error, message: "Govpay payment not found", payment_id: payment_id)
      raise ArgumentError, "invalid govpay_id"
    end
  end
end
