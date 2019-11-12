# frozen_string_literal: true

module WasteCarriersEngine
  class DeclarationFormsController < FormsController
    def new
      super(DeclarationForm, "declaration_form")
    end

    def create
      return unless super(DeclarationForm, "declaration_form")

      WasteCarriersEngine::ConvictionDataService.run(@transient_registration)
    end

    private

    def transient_registration_attributes
      params.fetch(:declaration_form, {}).permit(:declaration)
    end
  end
end
