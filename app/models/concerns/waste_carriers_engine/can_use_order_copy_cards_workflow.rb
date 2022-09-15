# frozen_string_literal: true

module WasteCarriersEngine
  module CanUseOrderCopyCardsWorkflow
    extend ActiveSupport::Concern
    include Mongoid::Document

    included do # rubocop:disable Metrics/BlockLength
      include AASM

      field :workflow_state, type: String

      aasm column: :workflow_state do
        # States / forms
        state :copy_cards_form, initial: true

        state :copy_cards_payment_form
        state :govpay_form
        state :worldpay_form
        state :copy_cards_bank_transfer_form
        state :copy_cards_order_completed_form

        # Transitions
        event :next do
          transitions from: :copy_cards_form,
                      to: :copy_cards_payment_form

          transitions from: :copy_cards_payment_form,
                      to: :govpay_form,
                      if: :paying_by_card_govpay?

          transitions from: :copy_cards_payment_form,
                      to: :worldpay_form,
                      if: :paying_by_card?

          transitions from: :copy_cards_payment_form,
                      to: :copy_cards_bank_transfer_form,
                      unless: :paying_by_card?

          transitions from: :copy_cards_bank_transfer_form,
                      to: :copy_cards_order_completed_form

          transitions from: :worldpay_form,
                      to: :copy_cards_order_completed_form

          transitions from: :govpay_form,
                      to: :copy_cards_order_completed_form
        end
      end
    end

    private

    def paying_by_card_govpay?
      WasteCarriersEngine::FeatureToggle.active?(:govpay_payments) && paying_by_card?
    end

    def paying_by_card?
      temp_payment_method == "card"
    end
  end
end
