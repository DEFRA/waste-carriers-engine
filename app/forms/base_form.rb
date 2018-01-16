class BaseForm
  include ActiveModel::Model
  attr_accessor :reg_identifier

  def initialize(transient_registration)
    # Get values from transient registration so form will be pre-filled
    @transient_registration = transient_registration
    self.reg_identifier = @transient_registration.reg_identifier
  end

  def submit(attributes, reg_identifier)
    # Additional attributes are set in individual form subclasses
    self.reg_identifier = reg_identifier

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

  def transient_registration_valid?
    return if @transient_registration.valid?
    @transient_registration.errors.each do |_attribute, message|
      errors[:base] << message
    end
  end
end
