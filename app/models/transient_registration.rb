class TransientRegistration
  include Mongoid::Document
  include CanHaveRegistrationAttributes
  include CanChangeWorkflowStatus

  validates_with RegIdentifierValidator
  validate :no_renewal_in_progress?, on: :create

  def renewal_attributes
    registration = Registration.where(reg_identifier: reg_identifier).first
    # Don't return object IDs as Mongo should generate new unique ones
    registration.attributes.except("_id")
  end

  private

  # Check if a transient renewal already exists for this registration so we don't have
  # multiple renewals in progress at once
  def no_renewal_in_progress?
    return unless TransientRegistration.where(reg_identifier: reg_identifier).exists?
    errors.add(:reg_identifier, :renewal_in_progress)
  end
end
