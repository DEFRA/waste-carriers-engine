# frozen_string_literal: true

module WasteCarriersEngine
  class DeregistrationCompleteFormsController < WasteCarriersEngine::FormsController

    def new
      super(DeregistrationCompleteForm, "deregistration_complete_form")

      @transient_registration.present? && @transient_registration.destroy!
    end

    private

    def find_or_initialize_transient_registration(token)
      @transient_registration = DeregisteringRegistration.where(token: token).first
    end
  end
end
