require "validates_email_format_of"

class ContactEmailValidator < ActiveModel::Validator
  def validate(record)
    return false unless fields_are_filled_in?(record)
    valid_format?(record)
    confirmation_matches?(record)
  end

  private

  def fields_are_filled_in?(record)
    valid = true

    unless record.contact_email.present?
      record.errors.add(:contact_email, :blank)
      valid = false
    end

    unless record.confirmed_email.present?
      record.errors.add(:confirmed_email, :blank)
      valid = false
    end

    valid
  end

  def valid_format?(record)
    # validate_email_format returns nil if the validation passes
    return true unless ValidatesEmailFormatOf.validate_email_format(record.contact_email)
    record.errors.add(:contact_email, :invalid_format)
    false
  end

  def confirmation_matches?(record)
    return true if record.contact_email == record.confirmed_email
    record.errors.add(:confirmed_email, :does_not_match)
    false
  end
end
