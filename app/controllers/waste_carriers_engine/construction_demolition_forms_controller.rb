# frozen_string_literal: true

module WasteCarriersEngine
  class ConstructionDemolitionFormsController < FormsController
    def new
      super(ConstructionDemolitionForm, "construction_demolition_form")
    end

    def create
      super(ConstructionDemolitionForm, "construction_demolition_form")
    end

    private

    def transient_registration_attributes
      params.require(:construction_demolition_form).permit(:construction_waste)
    end
  end
end
