class KeyPeopleValidator < ActiveModel::Validator
  def validate(record)
    return false unless fields_have_content?(record)
    validate_first_name(record)
    validate_last_name(record)
    DateOfBirthValidator.new.validate(record)
  end

  private

  def fields_have_content?(record)
    fields = [record.first_name, record.last_name, record.dob_day, record.dob_month, record.dob_year]
    fields.each do |field|
      return true if field.present? && field.to_s.length.positive?
    end
    record.errors.add(:base, :not_enough_key_people)
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
