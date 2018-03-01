class DateOfBirthValidator < ActiveModel::Validator
  def validate(record)
    fields = { day: record.dob_day, month: record.dob_month, year: record.dob_year }

    fields.each do |type, field|
      validate_field(record, type, field)
    end

    dob_is_a_date?(record)
  end

  private

  def validate_field(record, type, field)
    return unless field_present?(record, type, field)
    return unless field_is_integer?(record, type, field)
    field_is_in_correct_range?(record, type, field)
  end

  def field_present?(record, type, field)
    return true unless field.blank?
    error_message = "#{type}_blank".to_sym
    record.errors.add(:date_of_birth, error_message)
    false
  end

  def field_is_integer?(record, type, field)
    return true if field.is_a? Integer
    error_message = "#{type}_integer".to_sym
    record.errors.add(:date_of_birth, error_message)
    false
  end

  def field_is_in_correct_range?(record, type, field)
    ranges = {
      day: 1..31,
      month: 1..12,
      year: 1900..(Date.today.year.to_i)
    }

    return true if ranges[type].include?(field)
    error_message = "#{type}_range".to_sym
    record.errors.add(:date_of_birth, error_message)
    false
  end

  def dob_is_a_date?(record)
    return true if record.date_of_birth.is_a? Date
    record.errors.add(:date_of_birth, :not_a_date)
    false
  end
end
