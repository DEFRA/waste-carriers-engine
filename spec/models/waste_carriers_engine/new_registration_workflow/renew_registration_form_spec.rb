# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    subject { build(:new_registration, workflow_state: "renew_registration_form") }

    describe "#workflow_state" do
      context ":renew_registration_form state transitions" do
        context "on back" do
          include_examples "has back transition", previous_state: "start_form"
        end
      end
    end
  end
end
