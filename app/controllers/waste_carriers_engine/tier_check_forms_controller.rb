# frozen_string_literal: true

module WasteCarriersEngine
  class TierCheckFormsController < FormsController
    def new
      super(TierCheckForm, "tier_check_form")
    end

    def create
      super(TierCheckForm, "tier_check_form")
    end
  end
end
