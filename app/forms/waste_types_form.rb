class WasteTypesForm < BaseForm
  attr_accessor :reg_identifier, :only_amf

  def initialize(transient_registration)
    @transient_registration = transient_registration
    # Get values from transient registration so form will be pre-filled
    self.reg_identifier = @transient_registration.reg_identifier
    self.only_amf = @transient_registration.only_amf
  end

  def submit(params)
    # Define the params which are allowed
    self.reg_identifier = params[:reg_identifier]
    self.only_amf = params[:only_amf]

    # Update the transient registration with params from the registration if valid
    if valid?
      @transient_registration.reg_identifier = reg_identifier
      @transient_registration.only_amf = only_amf
      @transient_registration.save!
      true
    else
      false
    end
  end
end
