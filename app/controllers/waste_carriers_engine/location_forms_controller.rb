# frozen_string_literal: true

module WasteCarriersEngine
  class LocationFormsController < ::WasteCarriersEngine::FormsController
    def new
      super(LocationForm, "location_form")
    end

    def create
      super(LocationForm, "location_form")
    end

    private

    def transient_registration_attributes
      params.fetch(:location_form, {}).permit(:location)
    end
  end
end
