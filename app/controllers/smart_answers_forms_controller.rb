class SmartAnswersFormsController < FormsController
  def new
    set_transient_registration(params[:reg_identifier])
    @smart_answers_form = SmartAnswersForm.new(@transient_registration)
  end

  def create
    set_transient_registration(params[:smart_answers_form][:reg_identifier])
    @smart_answers_form = SmartAnswersForm.new(@transient_registration)

    submit_form(@smart_answers_form, params[:smart_answers_form])
  end
end
