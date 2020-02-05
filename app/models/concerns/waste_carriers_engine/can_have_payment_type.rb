# frozen_string_literal: true

module WasteCarriersEngine
  module CanHavePaymentType
    extend ActiveSupport::Concern
    include Mongoid::Document

    # rubocop:disable Metrics/BlockLength
    included do
      PAYMENT_TYPES = [
        CASH = "CASH",
        CHEQUE = "CHEQUE",
        POSTALORDER = "POSTALORDER",
        BANKTRANSFER = "BANKTRANSFER",
        WORLDPAY = "WORLDPAY",
        WORLDPAY_MISSED = "WORLDPAY_MISSED",
        REFUND = "REFUND",
        WRITEOFFSMALL = "WRITEOFFSMALL",
        WRITEOFFLARGE = "WRITEOFFLARGE",
        REVERSAL = "REVERSAL"
      ].freeze

      RECEIVABLE_PAYMENT_TYPES = [CASH, CHEQUE, POSTALORDER, BANKTRANSFER, WORLDPAY, WORLDPAY_MISSED].freeze

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
