# frozen_string_literal: true

module WasteCarriersEngine
  module Notify
    class DeregistrationEmailService < BaseSendEmailService
      private

      def notify_options
        {
          email_address: @registration.contact_email,
          template_id: "b9926a88-95db-47bd-96d4-0aaae7a322d3",
          personalisation: {
            reg_identifier: @registration.reg_identifier,
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
