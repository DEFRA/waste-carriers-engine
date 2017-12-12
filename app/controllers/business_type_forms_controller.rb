class BusinessTypeFormsController < FormsController
  def new
    set_transient_registration(params[:reg_identifier])
    @business_type_form = BusinessTypeForm.new(@transient_registration)
  end

  def create
    set_transient_registration(params[:business_type_form][:reg_identifier])
    @business_type_form = BusinessTypeForm.new(@transient_registration)

    submit_form(@business_type_form, params[:business_type_form])
  end
end
