# frozen_string_literal: true

module WasteCarriersEngine
  class EditCancelledFormsController < FormsController
    include UnsubmittableForm
    include CannotGoBackForm

    def new
      return unless super(EditCancelledForm, "edit_cancelled_form")

      EditCancellationService.run(edit_registration: @transient_registration)
    end
  end
end
