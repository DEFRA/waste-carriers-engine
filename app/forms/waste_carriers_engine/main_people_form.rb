# frozen_string_literal: true

module WasteCarriersEngine
  class MainPeopleForm < PersonForm
    include CanLimitNumberOfMainPeople

    attr_accessor :business_type

    def initialize(transient_registration)
      super
      # We only use this for the correct microcopy
      self.business_type = @transient_registration.business_type

      # If there's only one main person, we can pre-fill the fields so users can easily edit them
      prefill_form if can_only_have_one_main_person? && @transient_registration.main_people.present?
    end

    def person_type
      :key
    end

    validates_with MainPersonValidator

    private

    def prefill_form
      self.first_name = @transient_registration.main_people.first.first_name
      self.last_name = @transient_registration.main_people.first.last_name
      self.dob_day = @transient_registration.main_people.first.dob_day
      self.dob_month = @transient_registration.main_people.first.dob_month
      self.dob_year = @transient_registration.main_people.first.dob_year
    end

    # Adding the new main person directly to @transient_registration.key_people immediately updates the object,
    # regardless of validation. So instead we copy all existing people into a new array and modify that.
    def list_of_people_to_keep
      people = []

      # If there's only one main person allowed, we want to discard any existing main people, but keep people with
      # relevant convictions. Otherwise, we copy all the key_people, regardless of type.
      existing_people = if can_only_have_one_main_person?
                          @transient_registration.relevant_people
                        else
                          @transient_registration.key_people
                        end

      existing_people.each do |person|
        # We need to copy the person before adding to the array to avoid 'conflicting modifications' Mongo error (10151)
        people << person.clone
      end

      people
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
end
