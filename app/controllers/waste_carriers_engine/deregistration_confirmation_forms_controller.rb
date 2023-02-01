# frozen_string_literal: true

module WasteCarriersEngine
  class DeregistrationConfirmationFormsController < WasteCarriersEngine::FormsController

    def new; end

    private

    def validate_token
      redirect_to(page_path("invalid")) unless Registration.where(deregistration_token: params[:token]).first.present?
    end
  end
end
