class RenewalStartFormsController < FormsController

  # Unlike other forms, we don't use 'super' for this action because we need to run different validations
  def new
    set_transient_registration(params[:reg_identifier])

    if !form_matches_state?
      redirect_to_correct_form
    else
      @renewal_start_form = RenewalStartForm.new(@transient_registration)
      # Run validations now so we know if the registration exists and can be renewed
      @renewal_start_form.validate
    end
  end

  def create
    super(RenewalStartForm, "renewal_start_form")
  end
end
