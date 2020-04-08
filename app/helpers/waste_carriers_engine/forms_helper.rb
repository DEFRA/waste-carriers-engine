# frozen_string_literal: true

module WasteCarriersEngine
  module FormsHelper
    def show_smart_answers_results?(transient_registration)
      return false if transient_registration.charity?
      return false if transient_registration.new_registration? && transient_registration.tier_known?

      true
    end
  end
end
