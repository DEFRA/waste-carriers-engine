module WasteCarriersEngine
  module Govpay
    class Payment < Object
      def refundable?(amount = 0)
        refund.status == "available" &&
          refund.amount_available > refund.amount_submitted &&
          amount < refund.amount_available
      end

      alias refund refund_summary
    end
  end
end