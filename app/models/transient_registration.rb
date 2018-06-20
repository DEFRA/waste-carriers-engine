class TransientRegistration
  include Mongoid::Document
  include CanCalculateRenewalDates
  include CanChangeWorkflowStatus
  include CanCheckBusinessTypeChanges
  include CanHaveRegistrationAttributes
  include CanStripWhitespace

  validates :reg_identifier, reg_identifier: true
  validate :no_renewal_in_progress?, on: :create

  after_initialize :copy_data_from_registration

  # Attributes specific to the transient object - all others are in CanHaveRegistrationAttributes
  field :temp_cards, type: Integer
  field :temp_company_postcode, type: String
  field :temp_contact_postcode, type: String
  field :temp_os_places_error, type: Boolean
  field :temp_payment_method, type: String
  field :temp_tier_check, type: Boolean

  # Check if the user has changed the registration type, as this incurs an additional 40GBP charge
  def registration_type_changed?
    # Don't compare registration types if the new one hasn't been set
    return false unless registration_type
    original_registration_type = Registration.where(reg_identifier: reg_identifier).first.registration_type
    original_registration_type != registration_type
  end

  def fee_including_possible_type_change
    if registration_type_changed?
      Rails.configuration.renewal_charge + Rails.configuration.type_change_charge
    else
      Rails.configuration.renewal_charge
    end
  end

  def projected_renewal_end_date
    return unless expires_on.present?
    expiry_date_after_renewal(expires_on.to_date)
  end

  def total_to_pay
    charges = [Rails.configuration.renewal_charge]
    charges << Rails.configuration.type_change_charge if registration_type_changed?
    charges << total_registration_card_charge
    charges.sum
  end

  def total_registration_card_charge
    return 0 unless temp_cards.present?
    temp_cards * Rails.configuration.card_charge
  end

  def charity?
    business_type == "charity"
  end

  # Some business types should not have a company_no
  def company_no_required?
    return false if overseas?
    %w[limitedCompany limitedLiabilityPartnership].include?(business_type)
  end

  def company_no_changed?
    return false unless company_no_required?
    old_company_no = Registration.where(reg_identifier: reg_identifier).first.company_no.to_s
    # It was previously valid to have company_nos with less than 8 digits
    # The form prepends 0s to make up the length, so we should do this for the old number to match
    old_company_no = "0#{old_company_no}" while old_company_no.length < 8
    old_company_no != company_no
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
                                                "financeDetails",
                                                "declaredConvictions",
                                                "convictionSearchResult",
                                                "conviction_sign_offs",
                                                "declaration",
                                                "past_registrations")

    assign_attributes(strip_whitespace(attributes))
    remove_invalid_attributes
  end

  def remove_invalid_attributes
    validator = PhoneNumberValidator.new(attributes: :phone_number)
    return if validator.validate_each(self, :phone_number, phone_number)
    self.phone_number = nil
  end

  # Check if a transient renewal already exists for this registration so we don't have
  # multiple renewals in progress at once
  def no_renewal_in_progress?
    return unless TransientRegistration.where(reg_identifier: reg_identifier).exists?
    errors.add(:reg_identifier, :renewal_in_progress)
  end
end
