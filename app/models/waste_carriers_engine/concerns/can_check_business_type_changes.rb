module CanCheckBusinessTypeChanges
  extend ActiveSupport::Concern
  include Mongoid::Document

  included do
    def business_type_change_valid?
      return true if business_type == "overseas"

      old_type = Registration.where(reg_identifier: reg_identifier).first.business_type

      case old_type
      # If the old type and the new type are the same, it's valid
      when business_type
        true
      # Otherwise, check if the change is allowed based on the previous type
      when "authority"
        changing_to?("localAuthority")
      when "limitedCompany"
        changing_to?("limitedLiabilityPartnership")
      when "partnership"
        changing_to?("limitedLiabilityPartnership")
      when "publicBody"
        changing_to?("localAuthority")
      # There are no valid changes for charity or soleTrader
      else
        false
      end
    end

    private

    def changing_to?(value)
      business_type == value
    end
  end
end
