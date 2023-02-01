# frozen_string_literal: true

module WasteCarriersEngine
  module Notify
    class DeregistrationEmailService < BaseSendEmailService
      private

      def notify_options
        {
          email_address: @registration.contact_email,
          template_id: "0001e85a-7a09-4d6d-8988-ffb6fe4e2fd2",
          personalisation: {
            company_name: @registration.company_name,
            first_name: @registration.first_name,
            last_name: @registration.last_name,
            deregistration_link: DeregistrationMagicLinkService.run(registration: @registration)
          }
        }
      end
    end
  end
end
