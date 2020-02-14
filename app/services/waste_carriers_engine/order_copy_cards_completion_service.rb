# frozen_string_literal: true

module WasteCarriersEngine
  class OrderCopyCardsCompletionService < BaseService
    include CanMergeFinanceDetails

    attr_reader :transient_registration

    delegate :registration, to: :transient_registration

    def run(transient_registration)
      @transient_registration = transient_registration

      complete_order_copy_cards
    end

    private

    def complete_order_copy_cards
      update_registration

      delete_transient_registration

      send_confirmation_email unless @transient_registration.ad_contact_email?
    end

    def update_registration
      merge_finance_details

      registration.save!
    end

    def delete_transient_registration
      transient_registration.delete
    end

    def send_confirmation_email
      if @transient_registration.unpaid_balance?
        OrderCopyCardsMailer.send_awaiting_payment_email(registration, copy_cards_order).deliver_now
      else
        OrderCopyCardsMailer.send_order_completed_email(registration, copy_cards_order).deliver_now
      end
    rescue StandardError => e
      Airbrake.notify(e, registration_no: registration.reg_identifier) if defined?(Airbrake)
    end

    def copy_cards_order
      @_copy_cards_order ||= transient_registration.finance_details.orders.last
    end
  end
end
