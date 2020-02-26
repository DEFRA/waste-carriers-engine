# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    subject(:new_registration) { build(:new_registration, workflow_state: "renew_registration_form") }

    describe "#workflow_state" do
      context ":renew_registration_form state transitions" do
        context "on back" do
          it "can transition from a :renew_registration_form state to a :start_form" do
            new_registration.back

            expect(new_registration.workflow_state).to eq("start_form")
          end
        end
      end
    end
  end
end
