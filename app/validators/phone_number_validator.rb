class PhoneNumberValidator < ActiveModel::Validator
  def validate(record)
    return false unless record.phone_number.present?
    Phonelib.valid?(record.phone_number)
  end
end
