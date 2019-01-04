# frozen_string_literal: true

module WasteCarriersEngine
  module CanLimitNumberOfMainPeople
    extend ActiveSupport::Concern

    def enough_main_people?
      return false if number_of_existing_main_people < minimum_main_people

      true
    end

    def can_only_have_one_main_person?
      return false unless maximum_main_people

      maximum_main_people == 1
    end

    def maximum_main_people
      return unless business_type.present?

      limits = main_people_limits.fetch(business_type.to_sym, nil)
      return unless limits.present?

      limits[:maximum]
    end

    def minimum_main_people
      # Business type should always be set, but use 1 as the default, just in case
      return 1 unless business_type.present?

      limits = main_people_limits.fetch(business_type.to_sym, nil)
      return 1 unless limits.present?

      limits[:minimum]
    end

    def number_of_existing_main_people
      @transient_registration.main_people.count
    end

    private

    def main_people_limits
      {
        limitedCompany: { minimum: 1, maximum: nil },
        limitedLiabilityPartnership: { minimum: 1, maximum: nil },
        localAuthority: { minimum: 1, maximum: nil },
        overseas: { minimum: 1, maximum: nil },
        partnership: { minimum: 2, maximum: nil },
        soleTrader: { minimum: 1, maximum: 1 }
      }
    end
  end
end
