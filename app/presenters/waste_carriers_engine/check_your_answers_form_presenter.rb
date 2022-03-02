# frozen_string_literal: true

module WasteCarriersEngine
  class CheckYourAnswersFormPresenter < ResourceTypeFormPresenter
    include WasteCarriersEngine::CanPresentEntityDisplayName
    def show_smart_answers_results?
      return false if charity?
      return false if new_registration? && tier_known?

      true
    end
  end
end
