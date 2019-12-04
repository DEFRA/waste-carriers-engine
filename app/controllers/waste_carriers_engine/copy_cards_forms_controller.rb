# frozen_string_literal: true

module WasteCarriersEngine
  class CopyCardsFormsController < BaseOrderCopyCardsFormsController
    def new
      super(CopyCardsForm, "copy_cards_form")
    end

    def create
      super(CopyCardsForm, "copy_cards_form")
    end

    private

    def transient_registration_attributes
      params.fetch(:copy_cards_form).permit(:temp_cards)
    end
  end
end
