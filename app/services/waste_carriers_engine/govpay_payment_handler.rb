# frozen_string_literal: true

module WasteCarriersEngine
  class GovpayPaymentHandler
    def self.process(webhook_body)
      DefraRubyGovpay::GovpayWebhookPaymentService.run(webhook_body) do |args|
        payment_id = args[:id]
        status = args[:status]

        begin
          payment = GovpayFindPaymentService.run(payment_id: payment_id)
          return if payment.blank?

          registration = find_registration_for_payment(payment)
          return if registration.blank?

          previous_status = payment.govpay_payment_status

          update_payment_status(payment, status)

          complete_renewal_if_ready(registration, status)

          Rails.logger.info "Updated status from #{previous_status} to #{status} for payment #{payment_id}, registration #{registration.regIdentifier}"
        rescue StandardError => e
          Rails.logger.error "Error processing webhook for payment #{payment_id}: #{e}"
          Airbrake.notify "Error processing webhook for payment #{payment_id}", e
        end
      end
    end

    private

    def self.find_registration_for_payment(payment)
      registration = Registration.where("finance_details.payments.govpay_id" => payment.govpay_id).first

      if registration.blank?
        registration = TransientRegistration.where("finance_details.payments.govpay_id" => payment.govpay_id).first
      end

      registration
    end

    def self.update_payment_status(payment, status)
      payment.update(govpay_payment_status: status)
      payment.finance_details.update_balance
      (payment.finance_details.registration || payment.finance_details.transient_registration).save!
    end

    def self.complete_renewal_if_ready(registration, status)
      return unless registration.is_a?(WasteCarriersEngine::RenewingRegistration)
      return unless status == "success"

      RenewalCompletionService.new(registration).complete_renewal
    end
  end
end
