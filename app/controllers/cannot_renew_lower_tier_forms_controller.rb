class CannotRenewLowerTierFormsController < FormsController
  def new
    super(CannotRenewLowerTierForm, "cannot_renew_lower_tier_form")
  end

  # Override this method as user shouldn't be able to "submit" this page
  def create; end
end
