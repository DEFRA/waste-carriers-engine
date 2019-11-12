# frozen_string_literal: true

module WasteCarriersEngine
  class ConvictionDataService < BaseService
    def run(transient_registration)
      @transient_registration = transient_registration

      check_for_matches
      add_conviction_sign_off if declared_convictions? || matching_or_unknown_convictions?
    end

    private

    def check_for_matches
      WasteCarriersEngine::EntityMatchingService.run(@transient_registration)
    end

    def add_conviction_sign_off
      conviction_sign_off = ConvictionSignOff.new
      conviction_sign_off.confirmed = "no"

      @transient_registration.conviction_sign_offs = [conviction_sign_off]
    end

    def declared_convictions?
      @transient_registration.declared_convictions == "yes"
    end

    def matching_or_unknown_convictions?
      return true if @transient_registration.business_has_matching_or_unknown_conviction?
      return true if @transient_registration.key_person_has_matching_or_unknown_conviction?

      false
    end
  end
end
