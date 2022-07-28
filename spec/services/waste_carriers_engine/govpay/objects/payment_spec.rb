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
end