# frozen_string_literal: true

module WasteCarriersEngine
  module Notify
    class DeregistrationConfirmationEmailService < BaseSendEmailService
      private

      def notify_options
        {
          email_address: @registration.contact_email,
          template_id: "012a872c-2e79-4efb-a84e-5ce2bf26d0bf",
          personalisation: {
            reg_identifier: @registration.reg_identifier
          }
        }
      end
    end
  end
end
