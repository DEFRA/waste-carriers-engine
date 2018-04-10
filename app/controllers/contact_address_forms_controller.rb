class ContactAddressFormsController < FormsController
  def new
    super(ContactAddressForm, "contact_address_form")
  end

  def create
    super(ContactAddressForm, "contact_address_form")
  end

  def skip_to_manual_address
    set_transient_registration(params[:reg_identifier])

    @transient_registration.skip_to_manual_address! if form_matches_state?
    redirect_to_correct_form
  end
end
