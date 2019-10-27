# frozen_string_literal: true

module WasteCarriersEngine
  class SmartAnswersCheckerService
    attr_accessor :transient_registration

    delegate :construction_waste, :is_main_service, :only_amf, :other_businesses, to: :transient_registration

    def initialize(transient_registration)
      @transient_registration = transient_registration
    end

    def lower_tier?
      no_other_businesses_and_no_construction_waste? ||
        other_businesses_but_not_main_service_or_construction_waste? ||
        other_businesses_and_main_service_but_only_amf?
    end

    private

    def no_other_businesses_and_no_construction_waste?
      other_businesses == "no" && construction_waste == "no"
    end

    def other_businesses_but_not_main_service_or_construction_waste?
      other_businesses == "yes" && is_main_service == "no" && construction_waste == "no"
    end

    def other_businesses_and_main_service_but_only_amf?
      other_businesses == "yes" && is_main_service == "yes" && only_amf == "yes"
    end
  end
end
