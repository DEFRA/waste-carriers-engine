class ConstructionDemolitionForm < BaseForm
  attr_accessor :reg_identifier, :construction_waste

  def initialize(transient_registration)
    @transient_registration = transient_registration
    # Get values from transient registration so form will be pre-filled
    self.reg_identifier = @transient_registration.reg_identifier
    self.construction_waste = @transient_registration.construction_waste
  end

  def submit(params)
    # Define the params which are allowed
    self.reg_identifier = params[:reg_identifier]
    self.construction_waste = params[:construction_waste]

    # Update the transient registration with params from the registration if valid
    if valid?
      @transient_registration.reg_identifier = reg_identifier
      @transient_registration.construction_waste = construction_waste
      @transient_registration.save!
      true
    else
      false
    end
  end
end
