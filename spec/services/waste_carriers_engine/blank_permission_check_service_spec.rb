# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe BlankPermissionCheckService do
    let(:transient_registration) { double(:transient_registration) }
    let(:user) { double(:user) }
    let(:result) { double(:result) }
    let(:params) { { transient_registration: transient_registration, user: user } }

    describe ".run" do
      it "returns a valid result" do
        allow(PermissionChecksResult).to receive(:new).and_return(result)
        allow(result).to receive(:pass!)

        expect(described_class.run(params)).to eq(result)
      end
    end
  end
end
