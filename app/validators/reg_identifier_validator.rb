class RegIdentifierValidator < ActiveModel::Validator
  def validate(record)
    # Make sure the format of the reg_identifier is valid to prevent injection
    # Format should be CBDU or CBDL, followed by at least one digit
    if record.reg_identifier.blank? || !record.reg_identifier.match?(/^CBD[U|L][0-9]+$/)
      record.errors.add(:reg_identifier, :invalid_format)
    end

    # reg_identifier must match an existing registration
    return if Registration.where(reg_identifier: record.reg_identifier).exists?
    record.errors.add(:reg_identifier, :no_registration)
  end
end
