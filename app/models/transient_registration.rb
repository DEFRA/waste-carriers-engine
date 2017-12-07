class TransientRegistration < Registration
  include Mongoid::Document

  # TODO: Add state machine

  def valid_new_renewal?
    valid_reg_identifier? && no_renewal_in_progress? && registration_exists?
  end

  def get_renewal_attributes
    registration = Registration.where(regIdentifier: regIdentifier).first
    registration.attributes
  end

  private

  def valid_reg_identifier?
    # Make sure the format of the reg_identifier is valid to prevent injection
    # Format should be CBDU, followed by at least one digit
    return true if regIdentifier.match?(/^CBDU[0-9]+$/)
    # TODO: Throw error - "The registration identifier is not in the valid format"
    false
  end

  # Check if a transient renewal already exists for this registration so we don't have
  # multiple renewals in progress at once
  def no_renewal_in_progress?
    return true unless TransientRegistration.where(regIdentifier: regIdentifier).exists?
    # TODO: Throw error - "A renewal is already in progress for this registration"
    false
  end

  def registration_exists?
    return true if Registration.where(regIdentifier: regIdentifier).exists?
    # TODO: Throw error - "This registration does not exist"
    false
  end
end
