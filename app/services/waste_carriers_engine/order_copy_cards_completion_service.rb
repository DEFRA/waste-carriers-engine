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

      send_confirmation_email
    end

    def update_registration
      merge_finance_details

      registration.save!
    end

    def delete_transient_registration
      transient_registration.delete
    end

    def send_confirmation_email
      # TODO
      # RenewalMailer.send_renewal_complete_email(registration).deliver_now
      # rescue StandardError => e
      #   Airbrake.notify(e, registration_no: registration.reg_identifier) if defined?(Airbrake)
    end
  end
end
