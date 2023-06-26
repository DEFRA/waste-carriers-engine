# frozen_string_literal: true

module WasteCarriersEngine
  class PaymentMethodConfirmationForm < ::WasteCarriersEngine::BaseForm
    delegate :temp_payment_method, :temp_confirm_payment_method, to: :transient_registration

    validates :temp_confirm_payment_method, "waste_carriers_engine/yes_no": true

    def self.can_navigate_flexibly?
      false
    end
  end
end
