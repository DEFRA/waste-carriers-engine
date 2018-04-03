class PersonValidator < ActiveModel::Validator
  def validate(record)
    if record.fields_have_content?
      validate_individual_fields(record)
    else
      validate_number_of_people_in_type(record)
    end
  end

  private

  def validate_individual_fields(record)
    validate_first_name(record)
    validate_last_name(record)
    validate_position(record) if record.position?
    DateOfBirthValidator.new.validate(record)
  end

  def validate_number_of_people_in_type(record)
    return if record.enough_people_in_type?
    record.errors.add(:base, :not_enough_people_in_type, count: record.minimum_people_in_type)
  end

  def validate_first_name(record)
    return unless field_is_present?(record, :first_name)
    field_is_not_too_long?(record, :first_name, 35)
  end

  def validate_last_name(record)
    return unless field_is_present?(record, :last_name)
    field_is_not_too_long?(record, :last_name, 35)
  end

  def validate_position(record)
    return unless field_is_present?(record, :position)
    field_is_not_too_long?(record, :position, 35)
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
