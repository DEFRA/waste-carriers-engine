# frozen_string_literal: true

module WasteCarriersEngine
  module CanUseOrderCopyCardsWorkflow
    extend ActiveSupport::Concern
    include Mongoid::Document

    # rubocop:disable Metrics/BlockLength
    included do
      include AASM

      field :workflow_state, type: String

      aasm column: :workflow_state do
        # States / forms
        state :copy_cards_form, initial: true

        state :copy_cards_payment_form
        state :worldpay_form
        state :copy_cards_bank_transfer_form
        state :completed

        # Transitions
        event :next do
          transitions from: :copy_cards_form,
                      to: :copy_cards_payment_form

          transitions from: :copy_cards_payment_form,
                      to: :worldpay_form,
                      if: :paying_by_card?

          transitions from: :copy_cards_payment_form,
                      to: :copy_cards_bank_transfer_form,
                      unless: :paying_by_card?

          # TODO: after: :complete_order
          transitions from: :copy_cards_bank_transfer_form,
                      to: :completed

          # TODO: after: :complete_order
          transitions from: :worldpay_form,
                      to: :completed
        end

        event :back do
          transitions from: :copy_cards_payment_form,
                      to: :copy_cards_form

          transitions from: :worldpay_form,
                      to: :copy_cards_payment_form

          transitions from: :copy_cards_bank_transfer_form,
                      to: :copy_cards_payment_form
        end
      end
    end
    # rubocop:enable Metrics/BlockLength

    private

    def paying_by_card?
      temp_payment_method == "card"
    end

    def _complete_order
      # TODO
      # copy data to registration
      # update reegistration status (can be pending / awaiting payment) maybe not needed
      # delete transient object
    end
  end
end
