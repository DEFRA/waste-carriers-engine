# frozen_string_literal: true

module WasteCarriersEngine
  class OtherBusinessesFormsController < FormsController
    def new
      super(OtherBusinessesForm, "other_businesses_form")
    end

    def create
      super(OtherBusinessesForm, "other_businesses_form")
    end
  end
end
