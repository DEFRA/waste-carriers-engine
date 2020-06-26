# frozen_string_literal: true

module WasteCarriersEngine
  class CheckYourTierFormsController < ::WasteCarriersEngine::FormsController
    def new
      super(CheckYourTierForm, "check_your_tier")
    end

    def create
      super(CheckYourTierForm, "check_your_tier")
    end

    private

    def transient_registration_attributes
      params.fetch(:check_your_tier_form, {}).permit(:temp_check_your_tier)
    end
  end
end
