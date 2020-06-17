# frozen_string_literal: true

module WasteCarriersEngine
  class ServiceProvidedFormsController < ::WasteCarriersEngine::FormsController
    def new
      super(ServiceProvidedForm, "service_provided_form")
    end

    def create
      super(ServiceProvidedForm, "service_provided_form")
    end

    private

    def transient_registration_attributes
      params.fetch(:service_provided_form, {}).permit(:is_main_service)
    end
  end
end
