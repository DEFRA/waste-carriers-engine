class DobValidator < ActiveModel::Validator
  def validate(record)
    fields = { dob_day: record.dob_day, dob_month: record.dob_month, dob_year: record.dob_year }

    fields.each do |type, field|
      validate_field(record, type, field)
    end
  end

  private

  def validate_field(record, type, field)
    return unless field_present?(record, type, field)
    return unless field_is_integer?(record, type, field)
    field_is_in_correct_range?(record, type, field)
  end

  def field_present?(record, type, field)
    return true unless field.blank?
    record.errors.add(type, :blank)
  end

  def field_is_integer?(record, type, field)
    return true if field.is_a? Integer
    record.errors.add(type, :integer)
  end

  def field_is_in_correct_range?(record, type, field)
    ranges = {
      dob_day: 1..31,
      dob_month: 1..12,
      dob_year: 1900..(Date.today.year.to_i)
    }

    return true if ranges[type].include?(field)
    record.errors.add(type, :range)
  end
end
