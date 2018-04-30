class RenewalCompleteForm < BaseForm
  attr_accessor :contact_email, :registration_type, :certificate_link

  def initialize(transient_registration)
    super
    self.contact_email = @transient_registration.contact_email
    self.registration_type = @transient_registration.registration_type
    self.certificate_link = build_certificate_link
  end

  # Override BaseForm method as users shouldn't be able to submit this form
  def submit; end

  private

  def build_certificate_link
    registration = Registration.where(reg_identifier: reg_identifier).first
    return unless registration.present?
    id = registration.id
    root = Rails.configuration.wcrs_frontend_url
    "#{root}/registrations/#{id}/view?locale=en"
  end
end
