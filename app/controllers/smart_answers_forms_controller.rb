class SmartAnswersFormsController < FormsController
  def new
    set_transient_registration(params[:reg_identifier])

    if !form_matches_state?
      redirect_to_correct_form
    else
      @smart_answers_form = SmartAnswersForm.new(@transient_registration)
    end
  end

  def create
    set_transient_registration(params[:smart_answers_form][:reg_identifier])
    @smart_answers_form = SmartAnswersForm.new(@transient_registration)

    if !form_matches_state?
      redirect_to_correct_form
    else
      submit_form(@smart_answers_form, params[:smart_answers_form])
    end
  end
end
