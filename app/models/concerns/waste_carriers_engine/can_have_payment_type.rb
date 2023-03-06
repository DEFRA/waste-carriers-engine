# frozen_string_literal: true

module WasteCarriersEngine
  module CanHavePaymentType
    extend ActiveSupport::Concern
    include Mongoid::Document

    # rubocop:disable Metrics/BlockLength
    included do

      const_set(:PAYMENT_TYPES, [
                  CASH = "CASH",
                  CHEQUE = "CHEQUE",
                  POSTALORDER = "POSTALORDER",
                  BANKTRANSFER = "BANKTRANSFER",
                  WORLDPAY = "WORLDPAY",
                  WORLDPAY_MISSED = "WORLDPAY_MISSED",
                  MISSED_CARD = "MISSED_CARD",
                  GOVPAY = "GOVPAY",
                  REFUND = "REFUND",
                  WRITEOFFSMALL = "WRITEOFFSMALL",
                  WRITEOFFLARGE = "WRITEOFFLARGE",
                  REVERSAL = "REVERSAL"
                ])

      const_set(:RECEIVABLE_PAYMENT_TYPES, [
                  CASH,
                  CHEQUE,
                  POSTALORDER,
                  BANKTRANSFER,
                  WORLDPAY,
                  WORLDPAY_MISSED,
                  GOVPAY
                ])

      field :paymentType, as: :payment_type, type: String

      # TODO: Validations?

      def cash?
        payment_type == CASH
      end

      def cheque?
        payment_type == CHEQUE
      end

      def postal_order?
        payment_type == POSTALORDER
      end

      def bank_transfer?
        payment_type == BANKTRANSFER
      end

      def worldpay?
        payment_type == WORLDPAY
      end

      def worldpay_missed?
        payment_type == WORLDPAY_MISSED
      end

      def missed_card?
        payment_type == MISSED_CARD
      end

      def govpay?
        payment_type == GOVPAY
      end

      def refund?
        payment_type == REFUND
      end

      def writeoff_small?
        payment_type == WRITEOFFSMALL
      end

      def writeoff_large?
        payment_type == WRITEOFFLARGE
      end

      def reversal?
        payment_type == REVERSAL
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
end
