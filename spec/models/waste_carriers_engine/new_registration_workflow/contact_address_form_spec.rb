# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    subject { build(:new_registration, workflow_state: "contact_address_form") }

    describe "#workflow_state" do
      context ":contact_address_form state transitions" do
        context "on next" do
          context "when the user skip to a manual address" do
            subject { build(:new_registration, workflow_state: "contact_address_form", temp_os_places_error: "foo") }

            include_examples "can transition next to", next_state: "contact_address_manual_form"
          end

          include_examples "can transition next to", next_state: "check_your_answers_form"
        end

        context "on back" do
          include_examples "can transition back to", previous_state: "contact_postcode_form"
        end

        context "on skip_to_manual_address" do
          it "transitions to :contact_address_manual_form" do
            subject.skip_to_manual_address!

            expect(subject.workflow_state).to eq("contact_address_manual_form")
          end
        end
      end
    end
  end
end
