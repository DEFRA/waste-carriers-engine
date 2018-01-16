class ServiceProvidedForm < BaseForm
  attr_accessor :reg_identifier, :is_main_service

  def initialize(transient_registration)
    @transient_registration = transient_registration
    # Get values from transient registration so form will be pre-filled
    self.reg_identifier = @transient_registration.reg_identifier
    self.is_main_service = @transient_registration.is_main_service
  end

  def submit(params)
    # Define the params which are allowed
    self.reg_identifier = params[:reg_identifier]
    self.is_main_service = params[:is_main_service]

    # Update the transient registration with params from the registration if valid
    if valid?
      @transient_registration.reg_identifier = reg_identifier
      @transient_registration.is_main_service = is_main_service
      @transient_registration.save!
      true
    else
      false
    end
  end
end
