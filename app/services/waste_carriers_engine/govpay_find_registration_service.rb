# frozen_string_literal: true

module WasteCarriersEngine
  class GovpayFindRegistrationService < BaseService
    def run(payment:)
      return if payment.blank?

      registration = Registration.where("finance_details.payments.govpay_id" => payment.govpay_id).first

      if registration.blank?
        registration = TransientRegistration.where("finance_details.payments.govpay_id" => payment.govpay_id).first
      end

      registration
    end
  end
end
