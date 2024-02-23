# frozen_string_literal: true

module WasteCarriersEngine
  class ConvictionDataService < BaseService
    def run(transient_registration)
      @transient_registration = transient_registration

      check_for_matches
      add_conviction_sign_off(transient_registration.declared_convictions? || matching_or_unknown_convictions?)
    end

    private

    def check_for_matches
      WasteCarriersEngine::EntityMatchingService.run(@transient_registration)
    end

    def add_conviction_sign_off(convictions_present)
      conviction_sign_off = ConvictionSignOff.new
      conviction_sign_off.confirmed = "no" if convictions_present

      @transient_registration.conviction_sign_offs = [conviction_sign_off]
    end

    def matching_or_unknown_convictions?
      return true if @transient_registration.business_has_matching_or_unknown_conviction?
      return true if @transient_registration.key_person_has_matching_or_unknown_conviction?

      false
    end
  end
end
