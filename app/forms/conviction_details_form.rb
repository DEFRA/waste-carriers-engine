class ConvictionDetailsForm < PersonForm
  attr_accessor :position

  def position?
    true
  end

  def maximum_people_in_type
    nil
  end

  def minimum_people_in_type
    1
  end

  def number_of_existing_people_in_type
    @transient_registration.relevant_people.count
  end

  private

  def person_type
    "relevant"
  end

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
