# frozen_string_literal: true

module WasteCarriersEngine
  module Notify
    class CopyCardsOrderCompletedEmailService < BaseSendEmailService
      def run(registration:, order:)
        @order = order
        super
      end

      private

      def notify_options
        presenter = WasteCarriersEngine::OrderCopyCardsMailerPresenter.new(@registration, @order)

        {
          email_address: @registration.contact_email,
          template_id: "543a89cd-056e-4e9b-a55b-6416980f5472",
          personalisation: {
            reg_identifier: @registration.reg_identifier,
            first_name: @registration.first_name,
            last_name: @registration.last_name,
            total_cards: presenter.total_cards,
            ordered_on: presenter.ordered_on_formatted_string,
            total_paid: display_pence_as_pounds(presenter.total_paid)
          }
        }
      end
    end
  end
end
