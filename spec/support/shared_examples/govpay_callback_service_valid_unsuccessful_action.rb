# frozen_string_literal: true

RSpec.shared_examples "GovpayCallbackService valid unsuccessful action" do |valid_action, status|

  let(:govpay_validator_service) { instance_double(WasteCarriersEngine::GovpayValidatorService) }

  before { allow(WasteCarriersEngine::GovpayValidatorService).to receive(:new).and_return(govpay_validator_service) }

  context "when the params are valid" do
    before do
      allow(govpay_validator_service).to receive(valid_action).and_return(true)
    end

    it "returns true" do
      expect(govpay_service.public_send(valid_action)).to be true
    end

    it "updates the order status" do
      govpay_service.public_send(valid_action)
      expect(transient_registration.reload.finance_details.orders.first.govpay_status).to eq(status)
    end
  end

  context "when the params are invalid" do
    before do
      allow(govpay_validator_service).to receive(valid_action).and_return(false)
    end

    it "returns false" do
      expect(govpay_service.public_send(valid_action)).to be false
    end

    it "does not update the order" do
      unmodified_order = transient_registration.finance_details.orders.first
      govpay_service.public_send(valid_action)
      expect(transient_registration.reload.finance_details.orders.first).to eq(unmodified_order)
    end
  end
end
