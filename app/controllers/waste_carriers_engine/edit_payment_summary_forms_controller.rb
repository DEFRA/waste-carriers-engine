# frozen_string_literal: true

module WasteCarriersEngine
  class EditPaymentSummaryFormsController < FormsController
    def new
      super(EditPaymentSummaryForm, "edit_payment_summary_form")
    end

    def create
      super(EditPaymentSummaryForm, "edit_payment_summary_form")
    end

    private

    def transient_registration_attributes
      params.fetch(:edit_payment_summary_form, {}).permit(:temp_payment_method)
    end

    def fetch_presenters
      @order_and_total_presenter = OrderAndTotalPresenter.new(@edit_payment_summary_form, view_context)
    end
  end
end
