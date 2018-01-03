module CanCheckBusinessTypeChanges
  extend ActiveSupport::Concern
  include Mongoid::Document

  included do
    def business_type_change_valid?
      old_type = Registration.where(reg_identifier: reg_identifier).first.business_type

      case old_type
      # If there's no change to the business type, it's valid
      when business_type
        true
      # Otherwise, check based on what the previous type was
      when "authority"
        authority_valid?
      when "charity"
        charity_valid?
      when "limitedCompany"
        limited_company_valid?
      when "partnership"
        partnership_valid?
      when "publicBody"
        public_body_valid?
      when "soleTrader"
        sole_trader_valid?
      # If the old type was none of the above, it's invalid
      else
        false
      end
    end
  end

  private

  def authority_valid?
    return true if business_type == "localAuthority"
    return true if business_type == "overseas"
    false
  end

  def charity_valid?
    return true if business_type == "other"
    return true if business_type == "overseas"
    false
  end

  def limited_company_valid?
    return true if business_type == "limitedLiabilityPartnership"
    return true if business_type == "overseas"
    false
  end

  def partnership_valid?
    return true if business_type == "limitedLiabilityPartnership"
    return true if business_type == "overseas"
    false
  end

  def public_body_valid?
    return true if business_type == "localAuthority"
    return true if business_type == "overseas"
    false
  end

  def sole_trader_valid?
    return true if business_type == "overseas"
    false
  end
end
