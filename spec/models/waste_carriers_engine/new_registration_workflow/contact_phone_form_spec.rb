# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    subject { build(:new_registration, workflow_state: "contact_phone_form") }

    describe "#workflow_state" do
      context ":contact_phone_form state transitions" do
        context "on next" do
          include_examples "can transition next to", next_state: "contact_email_form"
        end

        context "on back" do
          include_examples "can transition back to", previous_state: "contact_name_form"
        end
      end
    end
  end
end