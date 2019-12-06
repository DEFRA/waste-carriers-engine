# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RegistrationCompletionService do
    let(:registration) { create(:registration, :has_required_data, :is_pending) }

    let(:service) { RegistrationCompletionService.run(registration: registration) }

    let(:current_time) { Time.new(2020, 1, 1) }

    describe "run" do
      before { allow(Time).to receive(:current).and_return(current_time) }

      context "when there is no unpaid balance" do
        before { allow(registration).to receive(:unpaid_balance?).and_return(false) }

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

        it "raises an error" do
          message = "Registration #{registration.reg_identifier} cannot be activated due to unpaid balance"

          expect { service }.to raise_error(RuntimeError, message)
        end
      end
    end
  end
end
