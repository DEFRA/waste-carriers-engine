class RenewalReceivedForm < BaseForm
  attr_accessor :contact_email

  def initialize(transient_registration)
    super
    self.contact_email = @transient_registration.contact_email
  end

  # Override BaseForm method as users shouldn't be able to submit this form
  def submit; end
end
