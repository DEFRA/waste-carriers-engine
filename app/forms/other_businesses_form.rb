class OtherBusinessesForm < BaseForm
  attr_accessor :reg_identifier, :other_businesses

  def initialize(transient_registration)
    @transient_registration = transient_registration
    # Get values from transient registration so form will be pre-filled
    self.reg_identifier = @transient_registration.reg_identifier
    self.other_businesses = @transient_registration.other_businesses
  end

  def submit(params)
    # Define the params which are allowed
    self.reg_identifier = params[:reg_identifier]
    self.other_businesses = params[:other_businesses]

    # Update the transient registration with params from the registration if valid
    if valid?
      @transient_registration.reg_identifier = reg_identifier
      @transient_registration.other_businesses = other_businesses
      @transient_registration.save!
      true
    else
      false
    end
  end
end
