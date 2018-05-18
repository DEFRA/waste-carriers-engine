class KeyPeopleValidator < ActiveModel::Validator
  def validate(record)
    valid_main_people?(record)
    valid_relevant_people?(record)
  end

  private

  def valid_main_people?(record)
    return false unless valid_number_of_people?(record, :key)
    return true unless record.main_people.present? && record.main_people.count.positive?

    valid = true

    record.main_people.each do |person|
      next if valid_person?(person, :key)
      record.errors.add(:base, :invalid_main_person)
      valid = false
    end

    valid
  end

  def valid_relevant_people?(record)
    return false unless valid_number_of_people?(record, :relevant)
    return true unless record.relevant_people.present? && record.relevant_people.count.positive?

    valid = true

    record.relevant_people.each do |person|
      next if valid_person?(person, :relevant)
      record.errors.add(:base, :invalid_relevant_person)
      valid = false
    end

    valid
  end

  def valid_number_of_people?(record, type)
    return true if record.enough_people?(type)
    message = "not_enough_#{type}_people".to_sym
    record.errors.add(:base, message, count: record.minimum_people(type))
    false
  end

  def valid_person?(person, type)
    PersonValidator.new(type: type, validate_fields: true).validate(person)
    !person.errors.present?
  end
end
