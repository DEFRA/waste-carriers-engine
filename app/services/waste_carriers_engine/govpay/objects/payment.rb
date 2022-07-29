# frozen_string_literal: true

module WasteCarriersEngine
  module Govpay
    class Payment < ::WasteCarriersEngine::Govpay::Object
      def refundable?(amount_requested = 0)
        refund.status == "available" &&
          refund.amount_available > refund.amount_submitted &&
          amount_requested <= refund.amount_available
      end

      def refund
        refund_summary
      end
    end
  end
end
