# frozen_string_literal: true

module WasteCarriersEngine
  class DeclareConvictionsFormsController < FormsController
    def new
      super(DeclareConvictionsForm, "declare_convictions_form")
    end

    def create
      super(DeclareConvictionsForm, "declare_convictions_form")
    end

    private

    def transient_registration_attributes
      params.fetch(:declare_convictions_form, {}).permit(:declared_convictions)
    end
  end
end
