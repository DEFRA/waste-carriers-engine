class ContactDetailsForm
  include ActiveModel::Model

  attr_accessor :firstName, :lastName, :phoneNumber, :contactEmail

  def initialize(registration)
    @registration = registration
  end

  # Validations
  validates :firstName, presence: true
  validates :lastName, presence: true
  validates :phoneNumber, presence: true
  validates :contactEmail, presence: true
end
