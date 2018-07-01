module WasteCarriersEngine
  class CardsFormsController < FormsController
    def new
      super(CardsForm, "cards_form")
    end

    def create
      super(CardsForm, "cards_form")
    end
  end
end
