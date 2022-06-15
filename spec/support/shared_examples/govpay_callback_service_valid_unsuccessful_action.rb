# frozen_string_literal: true

RSpec.shared_examples "GovpayCallbackService valid unsuccessful action" do |valid_action, status|
  # let(:transient_registration) do
  #   create(:renewing_registration,
  #          :has_required_data,
  #          :has_overseas_addresses,
  #          :has_finance_details,
  #          temp_cards: 0)
  # end
  # let(:current_user) { build(:user) }
  # let(:order) { transient_registration.finance_details.orders.first }
  # let(:payment) { WasteCarriersEngine::Payment.new_from_online_payment(transient_registration.finance_details.orders.first, nil) }

  # let(:govpay_service) { WasteCarriersEngine::GovpayCallbackService.new(payment.uuid) }

  # before do
  #   allow(Rails.configuration).to receive(:renewal_charge).and_return(10_500)

  #   transient_registration.prepare_for_payment(:govpay, current_user)
  # end

  context "when the params are valid" do
    before do
      allow_any_instance_of(WasteCarriersEngine::GovpayValidatorService).to receive(valid_action).and_return(true)
    end

    it "returns true" do
      expect(govpay_service.public_send(valid_action)).to eq(true)
    end

    it "updates the order status" do
      govpay_service.public_send(valid_action)
      expect(transient_registration.reload.finance_details.orders.first.govpay_status).to eq(status)
    end
  end

  context "when the params are invalid" do
    before do
      allow_any_instance_of(WasteCarriersEngine::GovpayValidatorService).to receive(valid_action).and_return(false)
    end

    it "returns false" do
      expect(govpay_service.public_send(valid_action)).to eq(false)
    end

    it "does not update the order" do
      unmodified_order = transient_registration.finance_details.orders.first
      govpay_service.public_send(valid_action)
      expect(transient_registration.reload.finance_details.orders.first).to eq(unmodified_order)
    end
  end
end
