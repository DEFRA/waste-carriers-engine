# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe WasteCarriersEngine::Govpay::Refund do
    subject(:refund) { described_class.new(params) }

    let(:params) { JSON.parse(file_fixture("govpay/get_refund_response_success.json").read) }

    describe "#status" do
      it { expect(refund.status).to eq "submitted" }
      it { expect(refund.success?).to be false }
      it { expect(refund.submitted?).to be true }

      context "with non-successful refund" do
        let(:params) { super().merge(status: "error") }

        it { expect(refund.success?).to be false }
        it { expect(refund.submitted?).to be false }
      end
    end
  end
end
