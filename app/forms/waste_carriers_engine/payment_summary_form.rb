# frozen_string_literal: true

module WasteCarriersEngine
  class PaymentSummaryForm < ::WasteCarriersEngine::BaseForm
    # delegate :temp_payment_method, to: :transient_registration

    attr_accessor :temp_payment_method, :registration_cards, :registration_card_charge, :total_charge, :card_confirmation_email

    validates :temp_payment_method, inclusion: { in: %w[card bank_transfer] }
    validates :card_confirmation_email, "defra_ruby/validators/email": true, if: :paying_by_card?

    def self.can_navigate_flexibly?
      false
    end

    def initialize(transient_registration)
      Rails.logger.debug("----- PAYMENT_SUMMARY_SUBMIT - initialize")
      super

      self.temp_payment_method = transient_registration.temp_payment_method
      self.registration_cards = transient_registration.temp_cards || 0
      self.registration_card_charge = transient_registration.total_registration_card_charge
      self.total_charge = transient_registration.total_to_pay
      self.card_confirmation_email = transient_registration.email_to_send_receipt
    end

    def submit(params)
      # Update our attributes. Needed for validation to work as expected
      assign_params(params)

      # We always want to save the selected payment method in case the user
      # comes back to the form
      attributes = {
        temp_payment_method: self.temp_payment_method
      }

      # We only want to save the email address if the user is paying by card
      attributes[:receipt_email] = self.card_confirmation_email if paying_by_card?

      super(attributes)
    end

    private

    def assign_params(params)
      self.temp_payment_method = params[:temp_payment_method]
      self.card_confirmation_email = params[:card_confirmation_email]
    end

    # TODO: This method is duplicated in
    # app/models/concerns/waste_carriers_engine/can_use_new_registration_workflow.rb.
    # Consider refactoring to being on the transient_registration itself
    def paying_by_card?
      self.temp_payment_method == "card"
    end
  end
end
