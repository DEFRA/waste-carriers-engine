# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe WasteCarriersEngine::Govpay::Refund do
    subject(:refund) { described_class.new(params) }

    let(:params) { JSON.parse(file_fixture("govpay/get_refund_response_success.json").read) }

    describe "#status" do
      it { expect(refund.status).to eq "success" }
      it { expect(refund.success?).to be true }

      context "with non-successful refund" do
        let(:params) { super().merge(status: "submitted") }

        it { expect(refund.success?).to be false }
      end
    end
  end
end
