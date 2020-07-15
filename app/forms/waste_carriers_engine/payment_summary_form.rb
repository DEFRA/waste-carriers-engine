# frozen_string_literal: true

module WasteCarriersEngine
  class PaymentSummaryForm < ::WasteCarriersEngine::BaseForm
    delegate :temp_payment_method, to: :transient_registration

    attr_accessor :type_change, :registration_cards, :registration_card_charge, :total_charge, :receipt_email

    validates :temp_payment_method, inclusion: { in: %w[card bank_transfer] }

    def self.can_navigate_flexibly?
      false
    end

    def initialize(transient_registration)
      super

      self.registration_cards = transient_registration.temp_cards || 0
      self.registration_card_charge = transient_registration.total_registration_card_charge
      self.total_charge = transient_registration.total_to_pay
      self.receipt_email = transient_registration.email_to_send_receipt
    end
  end
end
