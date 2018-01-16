class CannotRenewLowerTierForm < BaseForm
  def initialize(transient_registration)
    super
  end

  # Override BaseForm method as users shouldn't be able to submit this form
  def submit; end
end
