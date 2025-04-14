# frozen_string_literal: true

module WasteCarriersEngine
  class GovpayRefundHandler
    def self.process(webhook_body)
      DefraRubyGovpay::GovpayWebhookRefundService.run(webhook_body) do |args|
        refund_id = args[:id]
        payment_id = webhook_body["payment_id"]
        status = args[:status]

        begin
          refund = GovpayFindPaymentService.run(payment_id: refund_id)
          return if refund.blank?

          registration = find_registration_for_payment(refund)
          return if registration.blank?

          # Store previous status for logging
          previous_status = refund.govpay_payment_status

          # Use the existing service to update the refund status
          GovpayUpdateRefundStatusService.new.run(
            registration: registration,
            refund_id: refund_id,
            new_status: status
          )

          Rails.logger.info "Updated status from #{previous_status} to #{status} for refund #{refund_id}, payment #{payment_id}, registration #{registration.regIdentifier}"
        rescue StandardError => e
          Rails.logger.error "Error processing webhook for refund #{refund_id}, payment #{payment_id}: #{e}"
          Airbrake.notify "Error processing webhook for refund #{refund_id}, payment #{payment_id}", e
        end
      end
    end

    private

    def self.find_registration_for_payment(payment)
      # Try to find in registrations first
      registration = Registration.where("finance_details.payments.govpay_id" => payment.govpay_id).first

      # If not found, try to find in transient registrations
      if registration.blank?
        registration = TransientRegistration.where("finance_details.payments.govpay_id" => payment.govpay_id).first
      end

      registration
    end
  end
end
