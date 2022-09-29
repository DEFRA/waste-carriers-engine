# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe FlowPermissionChecksService do
    describe ".run" do
      let(:user) { double(:user) }
      let(:params) { { transient_registration: transient_registration, user: user } }
      let(:result) { double(:result) }

      before do
        allow(BlankPermissionCheckService).to receive(:run).and_return(result)
        allow(CeasedOrRevokedRegistrationPermissionChecksService).to receive(:run).and_return(result)
        allow(EditRegistrationPermissionChecksService).to receive(:run).and_return(result)
        allow(OrderCopyCardsRegistrationPermissionChecksService).to receive(:run).and_return(result)
        allow(RenewingRegistrationPermissionChecksService).to receive(:run).and_return(result)
      end

      context "when the transient object is a renewing registration" do
        let(:transient_registration) { RenewingRegistration.new }

        it "runs the correct permission check service and return a result" do
          expect(described_class.run(params)).to eq(result)

          expect(RenewingRegistrationPermissionChecksService).to have_received(:run).with(params)
        end
      end

      context "when the transient object is a new registration" do
        let(:transient_registration) { NewRegistration.new }

        it "runs the correct permission check service and return a result" do
          expect(described_class.run(params)).to eq(result)

          expect(BlankPermissionCheckService).to have_received(:run).with(params)
        end
      end

      context "when the transient object is an edit registration" do
        let(:transient_registration) { EditRegistration.new }

        it "runs the correct permission check service and return a result" do
          expect(described_class.run(params)).to eq(result)

          expect(EditRegistrationPermissionChecksService).to have_received(:run).with(params)
        end
      end

      context "when the transient object is an order copy cards registration" do
        let(:transient_registration) { OrderCopyCardsRegistration.new }

        it "runs the correct permission check service and return a result" do
          expect(described_class.run(params)).to eq(result)

          expect(OrderCopyCardsRegistrationPermissionChecksService).to have_received(:run).with(params)
        end
      end

      context "when the transient object is an CeasedOrRevokedRegistration" do
        let(:transient_registration) { CeasedOrRevokedRegistration.new }

        it "runs the correct permission check service and return a result" do
          expect(described_class.run(params)).to eq(result)

          expect(CeasedOrRevokedRegistrationPermissionChecksService).to have_received(:run).with(params)
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
