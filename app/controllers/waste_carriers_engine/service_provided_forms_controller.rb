# frozen_string_literal: true

module WasteCarriersEngine
  class ServiceProvidedFormsController < FormsController
    def new
      super(ServiceProvidedForm, "service_provided_form")
    end

    def create
      super(ServiceProvidedForm, "service_provided_form")
    end
  end
end
