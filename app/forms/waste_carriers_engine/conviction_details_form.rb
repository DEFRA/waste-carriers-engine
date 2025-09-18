# frozen_string_literal: true

module WasteCarriersEngine
  class ConvictionDetailsForm < PersonForm
    include CanLimitNumberOfRelevantPeople

    validates_with RelevantPersonFormValidator

    def position?
      true
    end

    def person_type
      :relevant
    end

    private

    # Adding the new person directly to @transient_registration.key_people immediately updates the object,
    # regardless of validation. So instead we copy all existing people into a new array and modify that.
    def list_of_people_to_keep
      transient_registration.key_people.map(&:clone)
    end

    def age_cutoff_date
      (Date.today - 16.years) + 1.day
    end
  end
end
