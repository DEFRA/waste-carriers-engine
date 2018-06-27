class RenewalReceivedForm < BaseForm
  attr_accessor :contact_email, :pending_convictions_check, :pending_payment

  def initialize(transient_registration)
    super
    self.contact_email = @transient_registration.contact_email
    self.pending_convictions_check = @transient_registration.conviction_check_required?
    self.pending_payment = (@transient_registration.temp_payment_method == "bank_transfer")
  end

  # Override BaseForm method as users shouldn't be able to submit this form
  def submit; end

  def dashboard_link(current_user)
    return unless current_user.present?
    id = current_user.id
    root = Rails.configuration.wcrs_frontend_url
    "#{root}/user/#{id}/registrations"
  end
end
