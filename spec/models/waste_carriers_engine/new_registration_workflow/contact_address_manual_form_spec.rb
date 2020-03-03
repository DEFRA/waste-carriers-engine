# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    subject { build(:new_registration, workflow_state: "contact_address_manual_form") }

    describe "#workflow_state" do
      context ":contact_address_manual_form state transitions" do
        context "on next" do
          include_examples "can transition next to", next_state: "check_your_answers_form"
        end

        context "on back" do
          context "when the business is based overseas" do
            subject { build(:new_registration, workflow_state: "contact_address_manual_form", location: "overseas") }

            include_examples "can transition back to", previous_state: "contact_email_form"
          end

          include_examples "can transition back to", previous_state: "contact_postcode_form"
        end
      end
    end
  end
end
