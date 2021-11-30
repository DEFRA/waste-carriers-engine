# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    subject { build(:new_registration, workflow_state: "contact_email_form") }

    describe "#workflow_state" do
      context ":contact_email_form state transitions" do
        context "on next" do
          context "when the business is based overseas" do
            subject { build(:new_registration, workflow_state: "contact_email_form", location: "overseas") }

            include_examples "has next transition", next_state: "contact_address_manual_form"
          end

          include_examples "has next transition", next_state: "contact_address_reuse_form"
        end

        context "on back" do
          include_examples "has back transition", previous_state: "contact_phone_form"
        end
      end
    end
  end
end
