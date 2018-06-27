# frozen_string_literal: true

module WasteCarriersEngine
  class PaymentSummaryFormsController < FormsController
    def new
      super(PaymentSummaryForm, "payment_summary_form")
    end

    def create
      super(PaymentSummaryForm, "payment_summary_form")
    end
  end
end
