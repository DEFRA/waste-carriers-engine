# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    subject { build(:new_registration, workflow_state: "check_your_answers_form") }

    describe "#workflow_state" do
      context ":check_your_answers_form state transitions" do
        context "on next" do
          include_examples "has next transition", next_state: "declaration_form"
        end

        context "on back" do
          context "when the contact address was manually entered" do
            let(:contact_address) { build(:address, :contact, :manual_uk) }
            subject { build(:new_registration, workflow_state: "check_your_answers_form", contact_address: contact_address) }

            include_examples "has back transition", previous_state: "contact_address_manual_form"
          end

          include_examples "has back transition", previous_state: "contact_address_form"
        end
      end
    end
  end
end
