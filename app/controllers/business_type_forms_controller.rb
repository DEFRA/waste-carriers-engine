class BusinessTypeFormsController < FormsController
  def new
    set_transient_registration(params[:reg_identifier])

    if !form_matches_state?
      redirect_to_correct_form
    else
      @business_type_form = BusinessTypeForm.new(@transient_registration)
    end
  end

  def create
    set_transient_registration(params[:business_type_form][:reg_identifier])
    @business_type_form = BusinessTypeForm.new(@transient_registration)

    if !form_matches_state?
      redirect_to_correct_form
    else
      submit_form(@business_type_form, params[:business_type_form])
    end
  end
end
