module CanCheckBusinessTypeChanges
  extend ActiveSupport::Concern
  include Mongoid::Document

  included do
    def business_type_change_valid?
      old_type = Registration.where(reg_identifier: reg_identifier).first.business_type

      case old_type
      # If the old type is the same as the new type, no change has happened and it's valid
      when business_type
        true

      # If the old type is sole trader and the new type is different
      when "soleTrader"
        case business_type
        when "overseas"
          true
        else
          false
        end

      # If the old type is partnership and the new type is different
      when "partnership"
        case business_type
        when "limitedLiabilityPartnership"
          true
        when "overseas"
          true
        else
          false
        end

      # If the old type is limited company and the new type is different
      when "limitedCompany"
        case business_type
        when "limitedLiabilityPartnership"
          true
        when "overseas"
          true
        else
          false
        end

      # If the old type is public body and the new type is different
      when "publicBody"
        case business_type
        when "localAuthority"
          true
        else
          false
        end

      # If the old type is charity and the new type is different
      when "charity"
        case business_type
        when "other"
          true
        when "overseas"
          true
        else
          false
        end

      # If the old type is authority and the new type is different
      when "authority"
        case business_type
        when "foo"
          true
        else
          false
        end

      # If the old type is none of the above
      else
        false
      end
    end
  end
end
