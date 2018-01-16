class RenewalStartForm < BaseForm
  include CanCalculateRenewalDates

  def initialize(transient_registration)
    super
  end

  def submit(params)
    attributes = {}

    super(attributes, params[:reg_identifier])
  end

  def projected_renewal_end_date
    expiry_date_after_renewal(@transient_registration.expires_on.to_date)
  end
end
