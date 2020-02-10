# frozen_string_literal: true

module WasteCarriersEngine
  class EditCompleteFormsController < FormsController
    def new
      super(EditCompleteForm, "edit_complete_form")
    end

    # Overwrite create and go_back as you shouldn't be able to submit or go back
    def create; end

    def go_back; end
  end
end
