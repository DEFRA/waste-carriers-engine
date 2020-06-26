# frozen_string_literal: true

module WasteCarriersEngine
  class YourTierFormsController < ::WasteCarriersEngine::FormsController
    def new
      super(YourTierForm, "your_tier_form")
    end

    def create
      super(YourTierForm, "your_tier_form")
    end

    private

    def transient_registration_attributes
      params.fetch(:your_tier_form, {})
    end
  end
end
