class ContactDetailsForm
  include ActiveModel::Model

  attr_accessor :firstName, :lastName, :phoneNumber, :contactEmail

  def initialize(registration)
    @registration = registration

    # Get values from registration so form will be pre-filled
    self.firstName = @registration.firstName
    self.lastName = @registration.lastName
    self.phoneNumber = @registration.phoneNumber
    self.contactEmail = @registration.contactEmail
  end

  # Validations
  validates :firstName, presence: true
  validates :lastName, presence: true
  validates :phoneNumber, presence: true
  validates :contactEmail, presence: true

  def submit(params)
    # Define the params which are allowed
    self.firstName = params[:firstName]
    self.lastName = params[:lastName]
    self.phoneNumber = params[:phoneNumber]
    self.contactEmail = params[:contactEmail]

    # Update the registration if valid
    if valid?
      @registration.firstName = firstName
      @registration.lastName = lastName
      @registration.phoneNumber = phoneNumber
      @registration.contactEmail = contactEmail
      @registration.save!
      true
    else
      false
    end
  end
end
