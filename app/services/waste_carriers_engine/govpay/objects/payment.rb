module WasteCarriersEngine
  module Govpay
    class Payment < Object
      def refundable?(amount_requested = 0)
        refund.status == "available" &&
          refund.amount_available > refund.amount_submitted &&
          amount_requested <= refund.amount_available
      end

      alias refund refund_summary
    end
  end
end