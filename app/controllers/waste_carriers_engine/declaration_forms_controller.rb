# frozen_string_literal: true

module WasteCarriersEngine
  class DeclarationFormsController < ::WasteCarriersEngine::FormsController
    def new
      super(DeclarationForm, "declaration_form")
    end

    def create
      return unless super(DeclarationForm, "declaration_form")

      WasteCarriersEngine::ConvictionDataService.run(@transient_registration) if should_check_convictions?
    end

    private

    def transient_registration_attributes
      params.fetch(:declaration_form, {}).permit(:declaration)
    end

    def should_check_convictions?
      (@transient_registration.is_a?(RenewingRegistration) || @transient_registration.is_a?(NewRegistration)) &&
        @transient_registration.upper_tier?
    end
  end
end
