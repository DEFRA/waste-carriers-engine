# frozen_string_literal: true

module WasteCarriersEngine
  module Notify
    class RegistrationPendingConvictionCheckEmailService < BaseSendEmailService
      private

      def notify_options
        {
          email_address: @registration.contact_email,
          template_id: "e7dbb0d2-feca-4f59-a5e6-576e5051f4e0",
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
