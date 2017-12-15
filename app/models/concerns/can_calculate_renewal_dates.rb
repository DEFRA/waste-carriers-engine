module CanCalculateRenewalDates
  extend ActiveSupport::Concern

  def expiry_date_after_renewal(current_expiry_date)
    current_expiry_date + 3.years
  end
end
