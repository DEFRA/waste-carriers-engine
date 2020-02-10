# frozen_string_literal: true

module WasteCarriersEngine
  class EditFormsController < FormsController
    def new
      super(EditForm, "edit_form")
    end

    def create
      super(EditForm, "edit_form")
    end

    private

    # rubocop:disable Naming/MemoizedInstanceVariableName
    def find_or_initialize_transient_registration(token)
      @transient_registration ||= EditRegistration.where(reg_identifier: token).first ||
                                  EditRegistration.where(token: token).first ||
                                  EditRegistration.new(reg_identifier: token)
    end
    # rubocop:enable Naming/MemoizedInstanceVariableName
  end
end
