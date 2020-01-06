# frozen_string_literal: true

module WasteCarriersEngine
  module CanBuildWorldpayXml
    extend ActiveSupport::Concern

    included do
      private

      def build_doctype(xml)
        xml.doc.create_internal_subset(
          "paymentService",
          "-//WorldPay/DTD WorldPay PaymentService v1/EN",
          "http://dtd.worldpay.com/paymentService_v1.dtd"
        )
      end

      def merchant_code
        @_merchant_code ||= Rails.configuration.worldpay_merchantcode
      end
    end
  end
end
