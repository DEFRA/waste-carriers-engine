class RenewalStartFormsController < FormsController

  # Unlike other forms, we don't use 'super' for this action because we need to run different validations
  def new
    return unless set_up_form(RenewalStartForm, "renewal_start_form", params[:reg_identifier])
    @renewal_start_form.validate
  end

  def create
    super(RenewalStartForm, "renewal_start_form")
  end
end
