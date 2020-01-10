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

    # rubocop:disable Naming/MemoizedInstanceVariableName
    def find_or_initialize_transient_registration(_id)
      @transient_registration ||= OrderCopyCardsRegistration.where(reg_identifier: _id).first ||
                                  OrderCopyCardsRegistration.where(_id: _id).first ||
                                  OrderCopyCardsRegistration.new(reg_identifier: _id)
    end
    # rubocop:enable Naming/MemoizedInstanceVariableName
  end
end
