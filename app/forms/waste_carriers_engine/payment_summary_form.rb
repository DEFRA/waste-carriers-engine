# frozen_string_literal: true

module WasteCarriersEngine
  class PaymentSummaryForm < ::WasteCarriersEngine::BaseForm
    delegate :temp_payment_method, to: :transient_registration
    delegate :receipt_email, to: :transient_registration, allow_nil: true

    attr_accessor :type_change, :registration_cards, :registration_card_charge, :total_charge

    validates :temp_payment_method, inclusion: { in: %w[card bank_transfer] }
    validates :receipt_email, "defra_ruby/validators/email": true, if: :paying_by_card?

    after_initialize :pre_populate_receipt_email

    def self.can_navigate_flexibly?
      false
    end

    def initialize(transient_registration)
      super

      self.registration_cards = transient_registration.temp_cards || 0
      self.registration_card_charge = transient_registration.total_registration_card_charge
      self.total_charge = transient_registration.total_to_pay
    end

    private

    # TODO: This method is duplicated in
    # app/models/concerns/waste_carriers_engine/can_use_new_registration_workflow.rb.
    # Consider refactoring to being on the transient_registration itself
    def paying_by_card?
      temp_payment_method == "card"
    end

    def pre_populate_receipt_email
      transient_registration.receipt_email ||= transient_registration.email_to_send_receipt
    end
  end
end
