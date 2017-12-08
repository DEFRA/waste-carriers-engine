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
    # Format should be CBDU, followed by at least one digit
    return unless reg_identifier.blank? || !reg_identifier.match?(/^CBDU[0-9]+$/)
    errors.add(:reg_identifier, "is not a valid format")
  end

  # Check if a transient renewal already exists for this registration so we don't have
  # multiple renewals in progress at once
  def no_renewal_in_progress?
    return unless TransientRegistration.where(reg_identifier: reg_identifier).exists?
    errors.add(:reg_identifier, "already has a renewal in progress")
  end

  def registration_exists?
    return if Registration.where(reg_identifier: reg_identifier).exists?
    errors.add(:reg_identifier, "does not exist")
  end
end
