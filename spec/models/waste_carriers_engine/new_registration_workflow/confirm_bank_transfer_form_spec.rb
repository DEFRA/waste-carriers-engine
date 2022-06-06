# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    subject { build(:new_registration, workflow_state: "confirm_bank_transfer_form") }

    describe "#workflow_state" do
      context ":confirm_bank_transfer_form state transitions" do
        context "on next" do
          include_examples "has next transition", next_state: "registration_received_pending_payment_form"

          it "set a metadata route" do
            allow(Rails.configuration).to receive(:metadata_route).and_return("test_route")

            expect { subject.next! }.to change { subject.metaData.route }.to("test_route")
          end
        end
      end
    end
  end
end
