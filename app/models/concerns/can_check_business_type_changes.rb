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
        matches_allowed_types?(["localAuthority"])
      when "charity"
        matches_allowed_types?(["overseas"])
      when "limitedCompany"
        matches_allowed_types?(["limitedLiabilityPartnership", "overseas"])
      when "partnership"
        matches_allowed_types?(["limitedLiabilityPartnership", "overseas"])
      when "publicBody"
        matches_allowed_types?(["localAuthority"])
      when "soleTrader"
        matches_allowed_types?(["overseas"])
      # If the old type was none of the above, it's invalid
      else
        false
      end
    end
  end

  private

  def matches_allowed_types?(valid_types)
    valid_types.include?(business_type)
  end
end
