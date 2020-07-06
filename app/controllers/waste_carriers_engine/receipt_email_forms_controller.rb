# frozen_string_literal: true

module WasteCarriersEngine
  class ReceiptEmailFormsController < ::WasteCarriersEngine::FormsController
    def new
      super(ReceiptEmailForm, "receipt_email_form")
    end

    def create
      super(ReceiptEmailForm, "receipt_email_form")
    end

    private

    def transient_registration_attributes
      params.fetch(:receipt_email_form, {}).permit(:receipt_email)
    end
  end
end
