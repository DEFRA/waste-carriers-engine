# frozen_string_literal: true

module WasteCarriersEngine
  module Notify
    class RenewalPendingPaymentEmailService < BaseSendEmailService
      private

      def notify_options
        {
          email_address: @registration.contact_email,
          template_id: "25a54b31-cdb0-4139-9ffe-50add03d572e",
          personalisation: {
            reg_identifier: @registration.reg_identifier,
            first_name: @registration.first_name,
            last_name: @registration.last_name,
            sort_code: payment_details(:sort_code),
            account_number: payment_details(:account_number),
            payment_due: payment_due,
            iban: payment_details(:iban),
            swiftbic: payment_details(:swiftbic),
            currency: payment_details(:currency)
          }
        }
      end

      def payment_details(key)
        I18n.t("waste_carriers_engine.payment_details.#{key}")
      end

      def payment_due
        display_pence_as_pounds(@registration.finance_details.balance)
      end
    end
  end
end
