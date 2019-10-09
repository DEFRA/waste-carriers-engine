# frozen_string_literal: true

module WasteCarriersEngine
  class CardsFormsController < FormsController
    def new
      super(CardsForm, "cards_form")
    end

    def create
      super(CardsForm, "cards_form")
    end

    private

    def transient_registration_attributes
      params.require(:cards_form).permit(:temp_cards)
    end
  end
end
