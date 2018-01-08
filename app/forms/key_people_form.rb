class KeyPeopleForm < BaseForm
  attr_accessor :reg_identifier
  attr_accessor :business_type

  def initialize(transient_registration)
    @transient_registration = transient_registration
    # Get values from transient registration so form will be pre-filled
    self.reg_identifier = @transient_registration.reg_identifier
    # We only use this for the correct microcopy
    self.business_type = @transient_registration.business_type
  end

  def submit(params)
    # Define the params which are allowed
    self.reg_identifier = params[:reg_identifier]
    # TODO: Add other params, eg self.field = params[:field]

    # Update the transient registration with params from the registration if valid
    if valid?
      @transient_registration.reg_identifier = reg_identifier
      # TODO: Add other params, eg @transient_registration.field = field
      @transient_registration.save!
      true
    else
      false
    end
  end
end
