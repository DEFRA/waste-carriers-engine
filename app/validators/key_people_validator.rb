class KeyPeopleValidator < ActiveModel::Validator
  def validate(record)
    valid_main_people?(record)
    valid_relevant_people?(record)
  end

  private

  def valid_main_people?(record)
    return false unless valid_number_of_people?(record, :key)
    return true unless record.main_people.present? && record.main_people.count.positive?
    valid_people?(record, record.main_people, :main)
  end

  def valid_relevant_people?(record)
    return false unless valid_number_of_people?(record, :relevant)
    return true unless record.relevant_people.present? && record.relevant_people.count.positive?
    valid_people?(record, record.relevant_people, :relevant)
  end

  def valid_number_of_people?(record, type)
    return true if record.enough_people?(type)
    message = "not_enough_#{type}_people".to_sym
    record.errors.add(:base, message, count: record.minimum_people(type))
    false
  end

  def valid_people?(record, people, type)
    valid = true
    people.each do |person|
      next if valid_person?(person, :relevant)
      message = "invalid_#{type}_person".to_sym
      record.errors.add(:base, message)
      valid = false
    end
    valid
  end

  def valid_person?(person, type)
    PersonValidator.new(type: type, validate_fields: true).validate(person)
    !person.errors.present?
  end
end
