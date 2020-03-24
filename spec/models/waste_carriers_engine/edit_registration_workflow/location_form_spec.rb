# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe EditRegistration do
    subject { build(:edit_registration, workflow_state: "location_form") }

    describe "#workflow_state" do
      context ":location_form state transitions" do
        context "on next" do
          subject { build(:edit_registration, workflow_state: "location_form") }

          include_examples "has next transition", next_state: "edit_form"

          context "when the registration has been edited from overseas to UK" do
            before do
              subject.location = "england"
              subject.registration.business_type = "overseas"
            end

            include_examples "has next transition", next_state: "business_type_form"
          end
        end

        context "on back" do
          include_examples "has back transition", previous_state: "edit_form"
        end
      end
    end
  end
end
