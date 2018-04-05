class BaseForm
  include ActiveModel::Model
  attr_accessor :reg_identifier, :transient_registration

  def initialize(transient_registration)
    # Get values from transient registration so form will be pre-filled
    @transient_registration = transient_registration
    self.reg_identifier = @transient_registration.reg_identifier
  end

  def submit(attributes, reg_identifier)
    # Additional attributes are set in individual form subclasses
    self.reg_identifier = reg_identifier

    attributes = strip_excess_whitespace(attributes)

    # Update the transient registration with params from the registration if valid
    if valid?
      @transient_registration.update_attributes(attributes)
      @transient_registration.save!
      true
    else
      false
    end
  end

  validates_with RegIdentifierValidator
  validate :transient_registration_valid?
  validates :reg_identifier, presence: true

  private

  def convert_to_boolean(value)
    if value == "true"
      true
    elsif value == "false"
      false
    end
  end

  def transient_registration_valid?
    return if @transient_registration.valid?
    @transient_registration.errors.each do |_attribute, message|
      errors[:base] << message
    end
  end

  # Whitespace stripping

  def strip_excess_whitespace(attributes)
    # Loop over each value and strip the whitespace, or strip the whitespace from values nested within it
    attributes.each_pair do |_key, value|
      strip_string(value) if value.is_a?(String)
      strip_hash(value) if value.is_a?(Hash)
      strip_array(value) if value.is_a?(Array)
    end
    attributes
  end

  def strip_string(string)
    string.strip!
  end

  def strip_hash(hash)
    strip_excess_whitespace(hash)
  end

  def strip_array(array)
    array.each do |nested_object|
      strip_excess_whitespace(nested_object.attributes)
    end
  end
end
