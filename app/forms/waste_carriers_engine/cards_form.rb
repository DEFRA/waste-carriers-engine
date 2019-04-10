# frozen_string_literal: true

module WasteCarriersEngine
  class CardsForm < BaseForm
    MAX_TEMP_CARDS = 999
    attr_accessor :temp_cards

    def initialize(transient_registration)
      super
      self.temp_cards = @transient_registration.temp_cards || 0
    end

    def submit(params)
      # Assign the params for validation and pass them to the BaseForm method for updating
      # If temp_cards is blank, sub in 0 so it passes validation
      self.temp_cards = if params[:temp_cards].present?
                          params[:temp_cards]
                        else
                          0
                        end
      attributes = { temp_cards: temp_cards }

      super(attributes, params[:reg_identifier])
    end

    validates(
      :temp_cards,
      numericality: {
        only_integer: true,
        greater_than_or_equal_to: 0,
        less_than_or_equal_to: MAX_TEMP_CARDS
      }
    )
  end
end
