# frozen_string_literal: true

module WasteCarriersEngine
  module Notify
    class RegistrationPendingOnlinePaymentEmailService < BaseSendEmailService
      TEMPLATE_ID = "c4296e7b-dac6-4b59-906e-2c509271626f"
      COMMS_LABEL = "Upper tier pending online payment"

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
