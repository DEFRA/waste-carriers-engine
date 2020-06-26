# frozen_string_literal: true

module WasteCarriersEngine
  class OtherBusinessesFormsController < ::WasteCarriersEngine::FormsController
    def new
      super(OtherBusinessesForm, "other_businesses_form")
    end

    def create
      super(OtherBusinessesForm, "other_businesses_form")
    end

    private

    def transient_registration_attributes
      params.fetch(:other_businesses_form, {}).permit(:other_businesses)
    end
  end
end
