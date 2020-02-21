# frozen_string_literal: true

module WasteCarriersEngine
  class EditCancelledFormsController < FormsController
    def new
      return unless super(EditCancelledForm, "edit_cancelled_form")

      EditCancellationService.run(edit_registration: @transient_registration)
    end

    # Overwrite create and go_back as you shouldn't be able to submit or go back
    def create; end

    def go_back; end
  end
end
