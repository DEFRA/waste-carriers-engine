# frozen_string_literal: true

module WasteCarriersEngine
  class PaymentSummaryFormsController < ::WasteCarriersEngine::FormsController
    def new
      return unless super(PaymentSummaryForm, "payment_summary_form")

      @presenter = ResourceTypeFormPresenter.new(@transient_registration)
    end

    def create
      @presenter = ResourceTypeFormPresenter.new(@transient_registration)

      super(PaymentSummaryForm, "payment_summary_form")
    end

    private

    def transient_registration_attributes
      params.fetch(:payment_summary_form, {}).permit(:temp_payment_method, :card_confirmation_email)
    end
  end
end
