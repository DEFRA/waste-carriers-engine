# frozen_string_literal: true

module WasteCarriersEngine
  class EditCancelledFormsController < FormsController
    include UnsubmittableForm

    def new
      return unless super(EditCancelledForm, "edit_cancelled_form")

      EditCancellationService.run(edit_registration: @transient_registration)
    end

    def go_back; end
  end
end
