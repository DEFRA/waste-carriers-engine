# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe FlowPermissionChecksService do
    describe ".run" do
      let(:user) { double(:user) }
      let(:params) { { transient_registration: transient_registration, user: user } }
      let(:result) { double(:result) }

      context "when the transient object is a renewing registration" do
        let(:transient_registration) { RenewingRegistration.new }

        it "runs the correct permission check service and return a result" do
          expect(RenewingRegistrationPermissionChecksService).to receive(:run).with(params).and_return(result)

          expect(described_class.run(params)).to eq(result)
        end
      end

      context "when the transient object is an edit registration" do
        let(:transient_registration) { EditRegistration.new }

        it "runs the correct permission check service and return a result" do
          expect(EditRegistrationPermissionChecksService).to receive(:run).with(params).and_return(result)

          expect(described_class.run(params)).to eq(result)
        end
      end

      context "when the transient object is an order copy cards registration" do
        let(:transient_registration) { OrderCopyCardsRegistration.new }

        it "runs the correct permission check service and return a result" do
          expect(OrderCopyCardsRegistrationPermissionChecksService).to receive(:run).with(params).and_return(result)

          expect(described_class.run(params)).to eq(result)
        end
      end

      context "when the transient object is an CeasedOrRevokedRegistration" do
        let(:transient_registration) { CeasedOrRevokedRegistration.new }

        it "runs the correct permission check service and return a result" do
          expect(CeasedOrRevokedRegistrationPermissionChecksService).to receive(:run).with(params).and_return(result)

          expect(described_class.run(params)).to eq(result)
        end
      end

      context "when there is no permission check service for the given transient object" do
        let(:transient_registration) { double(:transient_registration) }

        it "raises a specific error" do
          expect { described_class.run(params) }.to raise_error(FlowPermissionChecksService::MissingFlowPermissionChecksService)
        end
      end
    end
  end
end
