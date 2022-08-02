# frozen_string_literal: true

module WasteCarriersEngine
  module Govpay
    class Refund < ::WasteCarriersEngine::Govpay::Object
      def success?
        status == "success"
      end
    end
  end
end
