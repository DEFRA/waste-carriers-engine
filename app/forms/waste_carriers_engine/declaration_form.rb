# frozen_string_literal: true

module WasteCarriersEngine
  class DeclarationForm < BaseForm
    delegate :declaration, to: :transient_registration

    def self.can_navigate_flexibly?
      false
    end

    validates :declaration, inclusion: { in: [1] }
  end
end
