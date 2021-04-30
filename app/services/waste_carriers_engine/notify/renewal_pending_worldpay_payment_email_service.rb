# frozen_string_literal: true

module WasteCarriersEngine
  module Notify
    class RenewalPendingWorldpayPaymentEmailService < BaseSendEmailService
      private

      def notify_options
        {
          email_address: @registration.contact_email,
          template_id: "3da098e3-3db2-4c99-8e96-ed9d1a8ef227",
          personalisation: {
            reg_identifier: @registration.reg_identifier,
            registration_type: registration_type
          }
        }
      end
    end
  end
end
