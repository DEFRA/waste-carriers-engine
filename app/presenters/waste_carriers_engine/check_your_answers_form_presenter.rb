# frozen_string_literal: true

module WasteCarriersEngine
  class CheckYourAnswersFormPresenter < BasePresenter
    def new_registration?
      __getobj__.is_a?(WasteCarriersEngine::NewRegistration)
    end

    def renewal?
      __getobj__.is_a?(WasteCarriersEngine::RenewingRegistration)
    end
  end
end
