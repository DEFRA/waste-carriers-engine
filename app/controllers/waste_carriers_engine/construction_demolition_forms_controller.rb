# frozen_string_literal: true

module WasteCarriersEngine
  class ConstructionDemolitionFormsController < FormsController
    def new
      super(ConstructionDemolitionForm, "construction_demolition_form")
    end

    def create
      super(ConstructionDemolitionForm, "construction_demolition_form")
    end
  end
end
