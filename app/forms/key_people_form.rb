class KeyPeopleForm < PersonForm
  attr_accessor :business_type

  def initialize(transient_registration)
    super
    # We only use this for the correct microcopy
    self.business_type = @transient_registration.business_type

    # If there's only one key person, we can pre-fill the fields so users can easily edit them
    prefill_form if can_only_have_one_person_in_type? && @transient_registration.key_people.present?
  end

  def maximum_people_in_type
    return unless business_type.present?
    key_people_limits[business_type.to_sym][:maximum]
  end

  def minimum_people_in_type
    # Business type should always be set, but use 1 as the default, just in case
    return 1 unless business_type.present?
    key_people_limits[business_type.to_sym][:minimum]
  end

  private

  def person_type
    "key"
  end

  def prefill_form
    self.first_name = @transient_registration.key_people.first.first_name
    self.last_name = @transient_registration.key_people.first.last_name
    self.dob_day = @transient_registration.key_people.first.dob_day
    self.dob_month = @transient_registration.key_people.first.dob_month
    self.dob_year = @transient_registration.key_people.first.dob_year
  end

  # Adding the new key person directly to @transient_registration.keyPeople immediately updates the object,
  # regardless of validation. So instead we copy all existing people into a new array and modify that.
  def list_of_people_to_keep
    people = []

    # If there's only one key person allowed, we want to discard any existing key people, but keep people with
    # relevant convictions. Otherwise, we copy all the keyPeople, regardless of type.
    existing_people = if can_only_have_one_person_in_type?
                        @transient_registration.relevant_people
                      else
                        @transient_registration.keyPeople
                      end

    existing_people.each do |person|
      # We need to copy the person before adding to the array to avoid a 'conflicting modifications' Mongo error (10151)
      people << person.clone
    end

    people
  end

  def key_people_limits
    {
      limitedCompany: { minimum: 1, maximum: nil },
      limitedLiabilityPartnership: { minimum: 1, maximum: nil },
      localAuthority: { minimum: 1, maximum: nil },
      overseas: { minimum: 1, maximum: nil },
      partnership: { minimum: 2, maximum: nil },
      soleTrader: { minimum: 1, maximum: 1 }
    }
  end

  def age_cutoff_date
    age_limits = {
      limitedCompany: 16.years,
      limitedLiabilityPartnership: 17.years,
      localAuthority: 17.years,
      overseas: 17.years,
      partnership: 17.years,
      soleTrader: 17.years
    }

    (Date.today - age_limits[business_type.to_sym]) + 1.day
  end

  def age_limit_error_message
    "age_limit_#{business_type}".to_sym
  end
end
