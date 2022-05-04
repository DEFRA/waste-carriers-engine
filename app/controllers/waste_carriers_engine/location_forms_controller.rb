# frozen_string_literal: true

module WasteCarriersEngine
  class LocationFormsController < ::WasteCarriersEngine::FormsController
    include CanResetCompanyDetails

    def new
      super(LocationForm, "location_form")
    end

    def create
      super(LocationForm, "location_form")
      reset_company_attributes unless @transient_registration.company_no_required?
    end

    private

    def transient_registration_attributes
      params.fetch(:location_form, {}).permit(:location)
    end
  end
end
