# frozen_string_literal: true

module WasteCarriersEngine
  class CannotRenewTypeChangeFormsController < ::WasteCarriersEngine::FormsController
    include UnsubmittableForm

    def new
      super(CannotRenewTypeChangeForm, "cannot_renew_type_change_form")
    end
  end
end
