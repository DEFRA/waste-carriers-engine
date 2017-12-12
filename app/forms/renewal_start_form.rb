class RenewalStartForm < BaseForm
  attr_accessor :reg_identifier

  def initialize(transient_registration)
    @transient_registration = transient_registration
    # Get values from transient registration so form will be pre-filled
    self.reg_identifier = @transient_registration.reg_identifier
  end

  def submit(params)
    # Define the params which are allowed
    self.reg_identifier = params[:reg_identifier]

    @transient_registration.reg_identifier = reg_identifier

    # Update the transient registration with params from the registration if valid
    if valid?
      attributes = @transient_registration.renewal_attributes
      @transient_registration.assign_attributes(attributes)

      @transient_registration.save!
      true
    else
      false
    end
  end
end
