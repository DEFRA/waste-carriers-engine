class TransientRegistration
  include Mongoid::Document
  include CanHaveRegistrationAttributes

  # TODO: Add state machine

  def renewal_attributes
    registration = Registration.where(reg_identifier: reg_identifier).first
    # Don't return object IDs as Mongo should generate new unique ones
    registration.attributes.except("_id")
  end

  validate :valid_reg_identifier?
  validate :no_renewal_in_progress?
  validate :registration_exists?

  private

  def valid_reg_identifier?
    # Make sure the format of the reg_identifier is valid to prevent injection
    # Format should be CBDU or CBDL, followed by at least one digit
    return unless reg_identifier.blank? || !reg_identifier.match?(/^CBD[U|L][0-9]+$/)
    errors.add(:reg_identifier, :invalid_format)
  end

  # Check if a transient renewal already exists for this registration so we don't have
  # multiple renewals in progress at once
  def no_renewal_in_progress?
    return unless TransientRegistration.where(reg_identifier: reg_identifier).exists?
    errors.add(:reg_identifier, :renewal_in_progress)
  end

  def registration_exists?
    return if Registration.where(reg_identifier: reg_identifier).exists?
    errors.add(:reg_identifier, :no_registration)
  end
end
