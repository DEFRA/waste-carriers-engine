# frozen_string_literal: true

RSpec.shared_examples "WorldpayService valid unsuccessful action" do |valid_action, status|
  let(:transient_registration) do
    create(:renewing_registration,
           :has_required_data,
           :has_overseas_addresses,
           :has_finance_details,
           temp_cards: 0)
  end
  let(:current_user) { build(:user) }
  let(:worldpay_validator_service) { instance_double(WasteCarriersEngine::WorldpayValidatorService) }

  before do
    allow(Rails.configuration).to receive(:renewal_charge).and_return(10_500)
    allow(WasteCarriersEngine::WorldpayValidatorService).to receive(:new).and_return(worldpay_validator_service)

    transient_registration.prepare_for_payment(:worldpay, current_user)
  end

  let(:order) { transient_registration.finance_details.orders.first }
  # An incomplete set of params which should still be valid when we stub the validation service
  let(:params) do
    {
      orderKey: "#{Rails.configuration.worldpay_admin_code}^#{Rails.configuration.worldpay_merchantcode}^#{order.order_code}",
      paymentStatus: status,
      paymentAmount: order.total_amount,
      reg_identifier: transient_registration.reg_identifier
    }
  end

  let(:worldpay_service) do
    WasteCarriersEngine::WorldpayService.new(transient_registration, order, current_user, params)
  end

  context "when the params are valid" do
    before do
      allow(worldpay_validator_service).to receive(valid_action).and_return(true)
    end

    it "returns true" do
      expect(worldpay_service.public_send(valid_action)).to be true
    end

    it "updates the order status" do
      worldpay_service.public_send(valid_action)
      expect(transient_registration.reload.finance_details.orders.first.world_pay_status).to eq(status)
    end
  end

  context "when the params are invalid" do
    before do
      allow(worldpay_validator_service).to receive(valid_action).and_return(false)
    end

    it "returns false" do
      expect(worldpay_service.public_send(valid_action)).to be false
    end

    it "does not update the order" do
      unmodified_order = transient_registration.finance_details.orders.first
      worldpay_service.public_send(valid_action)
      expect(transient_registration.reload.finance_details.orders.first).to eq(unmodified_order)
    end
  end
end
