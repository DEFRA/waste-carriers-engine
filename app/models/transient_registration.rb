class TransientRegistration
  include Mongoid::Document
  include CanHaveRegistrationAttributes
  include CanChangeWorkflowStatus
  include CanCheckBusinessTypeChanges
  include CanStripWhitespace

  validates_with RegIdentifierValidator
  validate :no_renewal_in_progress?, on: :create

  after_initialize :copy_data_from_registration

  # Attributes specific to the transient object - all others are in CanHaveRegistrationAttributes
  field :temp_company_postcode, type: String
  field :temp_contact_postcode, type: String
  field :temp_os_places_error, type: Boolean

  # Check if the user has changed the registration type, as this incurs an additional 40GBP charge
  def registration_type_changed?
    original_registration_type = Registration.where(reg_identifier: reg_identifier).first.registration_type
    original_registration_type != registration_type
  end

  def total_fee
    if registration_type_changed?
      Rails.configuration.renewal_charge + Rails.configuration.type_change_charge
    else
      Rails.configuration.renewal_charge
    end
  end

  private

  def copy_data_from_registration
    # Don't try to get Registration data with an invalid reg_identifier
    return unless valid? && new_record?

    registration = Registration.where(reg_identifier: reg_identifier).first

    # Don't copy object IDs as Mongo should generate new unique ones
    # Don't copy smart answers as we want users to use the latest version of the questions
    attributes = registration.attributes.except("_id",
                                                "otherBusinesses",
                                                "isMainService",
                                                "constructionWaste",
                                                "onlyAMF",
                                                "addresses",
                                                "keyPeople",
                                                "declaredConvictions",
                                                "convictionSearchResult",
                                                "conviction_sign_offs")

    assign_attributes(strip_whitespace(attributes))
    remove_invalid_attributes
  end

  def remove_invalid_attributes
    self.phone_number = nil unless PhoneNumberValidator.new.validate(self)
  end

  # Check if a transient renewal already exists for this registration so we don't have
  # multiple renewals in progress at once
  def no_renewal_in_progress?
    return unless TransientRegistration.where(reg_identifier: reg_identifier).exists?
    errors.add(:reg_identifier, :renewal_in_progress)
  end
end
