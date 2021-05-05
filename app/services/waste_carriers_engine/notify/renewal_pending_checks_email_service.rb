# frozen_string_literal: true

module WasteCarriersEngine
  module Notify
    class RenewalPendingChecksEmailService < BaseSendEmailService
      private

      def notify_options
        {
          email_address: @registration.contact_email,
          template_id: "d2442022-4f4c-4edd-afc5-aaa0607dabdf",
          personalisation: {
            reg_identifier: @registration.reg_identifier,
            registration_type: registration_type
          }
        }
      end
    end
  end
end
