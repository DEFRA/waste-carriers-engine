# frozen_string_literal: true

module WasteCarriersEngine
  class DeclarationForm < BaseForm
    delegate :declaration, to: :transient_registration

    validates :declaration, inclusion: { in: [1] }

    def self.can_navigate_flexibly?
      false
    end

    def submit(attributes)
      return false unless super(attributes)

      if transient_registration.is_a?(WasteCarriersEngine::NewRegistration)
        transient_registration.update_attributes(reg_identifier: GenerateRegIdentifierService.run)
      end

      true
    end
  end
end
