# frozen_string_literal: true

module WasteCarriersEngine
  class DeclarationForm < BaseForm
    attr_accessor :declaration

    def self.can_navigate_flexibly?
      false
    end

    validates :declaration, inclusion: { in: [1] }

    def initialize(transient_registration)
      super

      self.declaration = transient_registration.declaration
    end

    def submit(params)
      # Assign the params for validation and pass them to the BaseForm method for updating
      self.declaration = params[:declaration].to_i
      attributes = { declaration: declaration }

      super(attributes)
    end
  end
end
