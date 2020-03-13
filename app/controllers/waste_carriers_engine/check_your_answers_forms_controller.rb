# frozen_string_literal: true

module WasteCarriersEngine
  class CheckYourAnswersFormsController < FormsController
    def new
      return unless super(CheckYourAnswersForm, "check_your_answers_form")

      @presenter = ResourceTypeFormPresenter.new(@transient_registration)
    end

    def create
      super(CheckYourAnswersForm, "check_your_answers_form")
    end
  end
end
