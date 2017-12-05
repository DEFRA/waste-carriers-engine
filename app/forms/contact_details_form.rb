class ContactDetailsForm
  include ActiveModel::Model

  attr_accessor :first_name, :last_name, :phone_number, :contact_email

  def initialize(registration)
    @registration = registration

    # Get values from registration so form will be pre-filled
    self.first_name = @registration.first_name
    self.last_name = @registration.last_name
    self.phone_number = @registration.phone_number
    self.contact_email = @registration.contact_email
  end

  # Validations
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone_number, presence: true
  validates :contact_email, presence: true

  def submit(params)
    # Define the params which are allowed
    self.first_name = params[:first_name]
    self.last_name = params[:last_name]
    self.phone_number = params[:phone_number]
    self.contact_email = params[:contact_email]

    # Update the registration if valid
    if valid?
      @registration.first_name = first_name
      @registration.last_name = last_name
      @registration.phone_number = phone_number
      @registration.contact_email = contact_email
      @registration.save!
      true
    else
      false
    end
  end
end
