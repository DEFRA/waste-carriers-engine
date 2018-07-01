module WasteCarriersEngine
  class CheckYourAnswersFormsController < FormsController
    def new
      super(CheckYourAnswersForm, "check_your_answers_form")
    end

    def create
      super(CheckYourAnswersForm, "check_your_answers_form")
    end
  end
end
