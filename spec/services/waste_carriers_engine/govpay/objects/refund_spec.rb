# frozen_string_literal: true

require "rails_helper"

RSpec.describe WasteCarriersEngine::Govpay::Refund do
  subject(:refund) { described_class.new(params) }
  let(:params) { JSON.parse(file_fixture("govpay/get_refund_response_success.json").read) }

  describe "#status" do
    it { expect(refund.status).to eq "submitted" }
    it { expect(refund.success?).to be false }

    context "with successful refund" do
      let(:params) { super().merge(status: "success") }

      it { expect(refund.success?).to be true }
    end
  end
end
