# frozen_string_literal: true

module WasteCarriersEngine
  module Notify
    class DeregistrationConfirmationEmailService < BaseSendEmailService
      TEMPLATE_ID = "012a872c-2e79-4efb-a84e-5ce2bf26d0bf"
      COMMS_LABEL = "Lower tier deregistration confirmation"

      private

      def notify_options
        {
          email_address: @registration.contact_email,
          template_id: TEMPLATE_ID,
          personalisation: {
            reg_identifier: @registration.reg_identifier,
            first_name: @registration.first_name,
            last_name: @registration.last_name
          }
        }
      end
    end
  end
end
