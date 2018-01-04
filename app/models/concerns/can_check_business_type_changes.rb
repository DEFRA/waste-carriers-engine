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
        compare_types(["localAuthority"])
      when "charity"
        compare_types(["other", "overseas"])
      when "limitedCompany"
        compare_types(["limitedLiabilityPartnership", "overseas"])
      when "partnership"
        compare_types(["limitedLiabilityPartnership", "overseas"])
      when "publicBody"
        compare_types(["localAuthority"])
      when "soleTrader"
        compare_types(["overseas"])
      # If the old type was none of the above, it's invalid
      else
        false
      end
    end
  end

  private

  def compare_types(valid_types)
    valid_types.include?(business_type)
  end
end
