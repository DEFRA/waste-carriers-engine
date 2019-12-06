# frozen_string_literal: true

module WasteCarriersEngine
  class TierCheckFormsController < FormsController
    def new
      super(TierCheckForm, "tier_check_form")
    end

    def create
      super(TierCheckForm, "tier_check_form")
    end

    private

    def transient_registration_attributes
      params.fetch(:tier_check_form, {}).permit(:temp_tier_check)
    end
  end
end
