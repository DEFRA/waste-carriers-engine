class CannotRenewLowerTierForm < BaseForm
  attr_accessor :reg_identifier

  def initialize(transient_registration)
    @transient_registration = transient_registration
    # Get values from transient registration so form will be pre-filled
    self.reg_identifier = @transient_registration.reg_identifier
  end
end
