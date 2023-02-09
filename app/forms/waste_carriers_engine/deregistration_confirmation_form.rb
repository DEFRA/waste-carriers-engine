# frozen_string_literal: true

module WasteCarriersEngine
  class DeregistrationConfirmationForm < WasteCarriersEngine::BaseForm
    include CannotGoBackForm

    delegate :temp_confirm_deregistration, to: :transient_registration

    validates :temp_confirm_deregistration, inclusion: { in: %w[yes no] }

    def self.can_navigate_flexibly?
      false
    end

  end
end
