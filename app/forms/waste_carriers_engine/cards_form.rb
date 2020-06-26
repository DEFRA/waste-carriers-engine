# frozen_string_literal: true

module WasteCarriersEngine
  class CardsForm < ::WasteCarriersEngine::BaseForm
    MAX_TEMP_CARDS = 999

    delegate :temp_cards, to: :transient_registration

    def self.can_navigate_flexibly?
      false
    end

    validates(
      :temp_cards,
      numericality: {
        only_integer: true,
        greater_than_or_equal_to: 0,
        less_than_or_equal_to: MAX_TEMP_CARDS
      }
    )

    def submit(params)
      params[:temp_cards] = 0 unless params[:temp_cards].present?

      super
    end
  end
end
