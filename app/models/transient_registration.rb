class TransientRegistration
  include Mongoid::Document
  include CanHaveRegistrationAttributes
  include CanChangeWorkflowStatus

  validates_with RegIdentifierValidator
  validate :no_renewal_in_progress?, on: :create

  after_initialize :copy_data_from_registration, on: :create

  private

  def copy_data_from_registration
    # Don't try to get Registration data with an invalid reg_identifier
    return unless valid?

    registration = Registration.where(reg_identifier: reg_identifier).first

    # Don't copy object IDs as Mongo should generate new unique ones
    assign_attributes(registration.attributes.except("_id"))
  end

  # Check if a transient renewal already exists for this registration so we don't have
  # multiple renewals in progress at once
  def no_renewal_in_progress?
    return unless TransientRegistration.where(reg_identifier: reg_identifier).exists?
    errors.add(:reg_identifier, :renewal_in_progress)
  end
end
