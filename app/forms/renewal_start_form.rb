class RenewalStartForm
  include ActiveModel::Model

  attr_accessor :reg_identifier

  def initialize(transient_registration)
    @transient_registration = transient_registration

    # Get values from transient registration so form will be pre-filled
    self.reg_identifier = @transient_registration.reg_identifier
  end

  validates :reg_identifier, presence: true

  def submit(params)
    # Define the params which are allowed
    self.reg_identifier = params[:reg_identifier]

    @transient_registration.reg_identifier = reg_identifier

    # Update the transient registration with params from the registration if valid
    if valid? && @transient_registration.valid?
      params = @transient_registration.renewal_attributes
      @transient_registration.update(params)

      @transient_registration.save!
      true
    else
      false
    end
  end
end
