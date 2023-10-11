# frozen_string_literal: true

module WasteCarriersEngine
  module Notify
    class InvitationInstructionsEmailService < DeviseSender
      private

      def notify_options(record, opts)
        {
          email_address: record.email,
          template_id: "5b5c1a42-b19b-4dc1-bece-4842f42edb65",
          personalisation: {
            invite_link: opts[:invite_url],
            service_link: opts[:service_url],
            expiry_date: opts[:invitation_due_at]
          }
        }
      end
    end
  end
end
