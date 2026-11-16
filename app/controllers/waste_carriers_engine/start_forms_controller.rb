# frozen_string_literal: true

module WasteCarriersEngine
  class StartFormsController < ::WasteCarriersEngine::FormsController
    before_action :check_service_closure

    def new
      super(StartForm, "start_form")
    end

    def create
      super(StartForm, "start_form")
    end

    private

    def check_service_closure
      return unless FeatureToggle.active?(:service_closure)

      redirect_to page_path("service_closed")
    end

    def transient_registration_attributes
      params.fetch(:start_form, {}).permit(:temp_start_option)
    end

    def find_or_initialize_transient_registration(token)
      @transient_registration = NewRegistration.where(token: token).first ||
                                NewRegistration.new
    end

  end
end
