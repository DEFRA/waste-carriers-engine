# frozen_string_literal: true

module WasteCarriersEngine
  class CopyCardsForm < CardsForm
    validates(
      :temp_cards,
      numericality: {
        only_integer: true,
        greater_than_or_equal_to: 1,
        less_than_or_equal_to: MAX_TEMP_CARDS
      }
    )

    def self.can_navigate_flexibly?
      true
    end
  end
end
