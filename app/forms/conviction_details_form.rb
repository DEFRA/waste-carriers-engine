class ConvictionDetailsForm < PersonForm
  include CanLimitNumberOfRelevantPeople
  include CanNavigateFlexibly

  def position?
    true
  end

  def person_type
    :relevant
  end

  validates_with RelevantPersonValidator

  private

  # Adding the new person directly to @transient_registration.keyPeople immediately updates the object,
  # regardless of validation. So instead we copy all existing people into a new array and modify that.
  def list_of_people_to_keep
    people = []

    @transient_registration.keyPeople.each do |person|
      # We need to copy the person before adding to the array to avoid a 'conflicting modifications' Mongo error (10151)
      people << person.clone
    end

    people
  end

  def age_cutoff_date
    (Date.today - 16.years) + 1.day
  end
end
