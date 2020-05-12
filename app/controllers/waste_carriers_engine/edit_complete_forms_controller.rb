# frozen_string_literal: true

module WasteCarriersEngine
  class EditCompleteFormsController < FormsController
    include UnsubmittableForm

    def new
      return unless super(EditCompleteForm, "edit_complete_form")

      EditCompletionService.run(edit_registration: @transient_registration)
    end

    def go_back; end
  end
end
