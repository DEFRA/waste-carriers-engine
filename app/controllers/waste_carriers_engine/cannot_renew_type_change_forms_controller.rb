class CannotRenewTypeChangeFormsController < FormsController
  def new
    super(CannotRenewTypeChangeForm, "cannot_renew_type_change_form")
  end

  # Override this method as user shouldn't be able to "submit" this page
  def create; end
end
