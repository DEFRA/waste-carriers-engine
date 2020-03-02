# frozen_string_literal: true

module WasteCarriersEngine
  class StartFormsController < FormsController
    def new
      super(StartForm, "start_form")
    end

    def create
      super(StartForm, "start_form")
    end

    private

    def transient_registration_attributes
      params.fetch(:start_form, {}).permit(:start_option)
    end

    def find_or_initialize_transient_registration(token)
      @transient_registration = NewRegistration.where(token: token).first ||
                                NewRegistration.new
    end

  end
end
