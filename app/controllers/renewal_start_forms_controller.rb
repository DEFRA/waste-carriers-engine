class RenewalStartFormsController < FormsController
  def new
    set_transient_registration(params[:reg_identifier])
    redirect_to_correct_form
    @renewal_start_form = RenewalStartForm.new(@transient_registration)
    # Run validations now so we know if the registration exists and can be renewed
    @renewal_start_form.validate
  end

  def create
    set_transient_registration(params[:renewal_start_form][:reg_identifier])
    @renewal_start_form = RenewalStartForm.new(@transient_registration)

    submit_form(@renewal_start_form, params[:renewal_start_form])
  end
end
