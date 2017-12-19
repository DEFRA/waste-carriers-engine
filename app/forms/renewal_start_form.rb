class RenewalStartForm < BaseForm
  include CanCalculateRenewalDates

  attr_accessor :reg_identifier

  def initialize(transient_registration)
    @transient_registration = transient_registration
    # Get values from transient registration so form will be pre-filled
    self.reg_identifier = @transient_registration.reg_identifier
  end

  def submit(params)
    # Define the params which are allowed
    self.reg_identifier = params[:reg_identifier]

    # Update the transient registration with params from the registration if valid
    if valid?
      @transient_registration.reg_identifier = reg_identifier
      @transient_registration.save!
      true
    else
      false
    end
  end

  def projected_renewal_end_date
    expiry_date_after_renewal(@transient_registration.expires_on.to_date)
  end
end
