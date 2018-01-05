class BusinessTypeForm < BaseForm
  attr_accessor :reg_identifier, :business_type

  def initialize(transient_registration)
    @transient_registration = transient_registration
    # Get values from transient registration so form will be pre-filled
    self.reg_identifier = @transient_registration.reg_identifier
    self.business_type = @transient_registration.business_type
  end

  validates :business_type, presence: true
  validates :business_type, inclusion: { in: %w[limitedCompany
                                                limitedLiabilityPartnership
                                                localAuthority
                                                other
                                                overseas
                                                partnership
                                                soleTrader] }

  def submit(params)
    # Define the params which are allowed
    self.reg_identifier = params[:reg_identifier]
    self.business_type = params[:business_type]

    # Update the transient registration with params from the registration if valid
    if valid?
      @transient_registration.reg_identifier = reg_identifier
      @transient_registration.business_type = business_type
      @transient_registration.save!
      true
    else
      false
    end
  end
end
