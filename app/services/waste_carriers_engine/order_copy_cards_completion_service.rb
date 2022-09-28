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

      send_confirmation_email unless @transient_registration.assisted_digital?
    end

    def update_registration
      merge_finance_details
      registration.save!

      # Log the order items only if payment is complete.
      if !@transient_registration.unpaid_balance?
        OrderItemLog.create_from_registration(registration, Time.current)
      else
        # Orders paid using alternate payment methods are not currently
        # included in the card order export. Just log these.
        Rails.logger.warn("Copy card order payment incomplete "\
        "for registration #{@transient_registration.reg_identifier}")
      end
    end

    def delete_transient_registration
      transient_registration.delete
    end

    def send_confirmation_email
      if @transient_registration.unpaid_balance?
        Notify::CopyCardsAwaitingPaymentEmailService
          .run(registration: registration, order: copy_cards_order)
      else
        Notify::CopyCardsOrderCompletedEmailService
          .run(registration: registration, order: copy_cards_order)
      end
    rescue StandardError => e
      Airbrake.notify(e, registration_no: registration.reg_identifier) if defined?(Airbrake)
    end

    def copy_cards_order
      @_copy_cards_order ||= transient_registration.finance_details.orders.last
    end
  end
end
