class KeyPeopleValidator < ActiveModel::Validator
  def validate(record)
    if record.fields_have_content?
      validate_first_name(record)
      validate_last_name(record)
      DateOfBirthValidator.new.validate(record)
    elsif already_has_enough_key_people?(record)
      true
    else
      record.errors.add(:base, :not_enough_key_people, count: record.minimum_key_people)
    end
  end

  private

  def already_has_enough_key_people?(record)
    return true unless record.minimum_key_people.present?
    return true unless record.number_of_existing_key_people < record.minimum_key_people
    false
  end

  def validate_first_name(record)
    return unless field_is_present?(record, :first_name)
    field_is_not_too_long?(record, :first_name, 35)
  end

  def validate_last_name(record)
    return unless field_is_present?(record, :last_name)
    field_is_not_too_long?(record, :last_name, 35)
  end

  def field_is_present?(record, field)
    return true if record.send(field).present?
    record.errors.add(field, :blank)
    false
  end

  def field_is_not_too_long?(record, field, length)
    return true if record.send(field).length < length
    record.errors.add(field, :too_long)
    false
  end
end
