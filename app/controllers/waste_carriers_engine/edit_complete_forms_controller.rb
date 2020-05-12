# frozen_string_literal: true

module WasteCarriersEngine
  class EditCompleteFormsController < FormsController
    include UnsubmittableForm
    include CannotGoBackForm

    def new
      return unless super(EditCompleteForm, "edit_complete_form")

      EditCompletionService.run(edit_registration: @transient_registration)
    end
  end
end
