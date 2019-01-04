# frozen_string_literal: true

module WasteCarriersEngine
  class SmartAnswersCheckerService
    def initialize(transient_registration)
      @construction_waste = transient_registration.construction_waste
      @is_main_service = transient_registration.is_main_service
      @only_amf = transient_registration.only_amf
      @other_businesses = transient_registration.other_businesses
    end

    def lower_tier?
      return true if @other_businesses == "no" && @construction_waste == "no"
      return true if @other_businesses == "yes" && @is_main_service == "no" && @construction_waste == "no"
      return true if @other_businesses == "yes" && @is_main_service == "yes" && @only_amf == "yes"

      false
    end
  end
end
