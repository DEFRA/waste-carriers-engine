# frozen_string_literal: true

module WasteCarriersEngine
  class CopyCardsFormsController < FormsController
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

    def find_or_initialize_transient_registration(token)
      @transient_registration = OrderCopyCardsRegistration.where(token: token).first ||
                                OrderCopyCardsRegistration.new(reg_identifier: token)
    end
  end
end
