# frozen_string_literal: true

require "rails_helper"
# require "waste_carriers_engine/govpay"

RSpec.describe WasteCarriersEngine::Govpay::Payment do
  subject(:payment) { described_class.new(params) }
  let(:params) { JSON.parse(file_fixture("govpay/get_payment_response_success.json").read) }

  describe "#refundable?" do
    context "when refundable" do
      it { expect(payment.refundable?).to be true }
    end
  end

  describe "parsing arrays" do
    let(:params) { super().merge(array: [1, 2, 3]) }

    it "creats an array openstruct" do
      expect(payment.array).to eq [1, 2, 3]
    end
  end
end
