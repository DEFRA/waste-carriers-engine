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

    def find_or_initialize_transient_registration(reg_identifier)
      @transient_registration = OrderCopyCardsRegistration.where(reg_identifier: reg_identifier).first ||
                                OrderCopyCardsRegistration.new(reg_identifier: reg_identifier)
    end
  end
end
