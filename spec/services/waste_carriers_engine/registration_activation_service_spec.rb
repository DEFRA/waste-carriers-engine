# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RegistrationActivationService do
    let(:registration) { create(:registration, :has_required_data, :is_pending) }

    let(:service) { RegistrationActivationService.run(registration: registration) }

    let(:current_time) { Time.new(2020, 1, 1) }

    describe "run" do
      before { allow(Time).to receive(:current).and_return(current_time) }

      context "when there is no unpaid balance or pending convictions check" do
        before do
          allow(registration).to receive(:unpaid_balance?).and_return(false)
          allow(registration).to receive(:pending_manual_conviction_check?).and_return(false)

          expect(RegistrationConfirmationService)
            .to receive(:run)
            .with(registration: registration)
            .once
        end

        it "updates the date_activated" do
          registration.metaData.update_attributes(date_activated: nil)

          expect { service }.to change { registration.metaData.reload.date_activated }.to(current_time)
        end

        it "activates the registration" do
          expect { service }.to change { registration.active? }.from(false).to(true)
        end
      end

      context "when the balance is unpaid" do
        before { allow(registration).to receive(:unpaid_balance?).and_return(true) }

        it "does not activates the registration" do
          expect { service }.to_not change { registration.active? }
        end
      end

      context "when the registration has a pending convictions check" do
        before { allow(registration).to receive(:pending_manual_conviction_check?).and_return(true) }

        it "does not activates the registration" do
          expect { service }.to_not change { registration.active? }
        end
      end
    end
  end
end
