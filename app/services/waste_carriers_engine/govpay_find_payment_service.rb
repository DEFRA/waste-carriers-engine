# frozen_string_literal: true

module WasteCarriersEngine
  class GovpayFindPaymentService < WasteCarriersEngine::BaseService
    def run(payment_id:)
      @last_error = nil

      payment = find_payment_in_registration(payment_id)

      payment ||= find_payment_in_transient_registration(payment_id)

      payment || handle_payment_not_found(payment_id)
    end

    private

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
