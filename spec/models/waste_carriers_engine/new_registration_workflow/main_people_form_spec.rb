# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    subject { build(:new_registration, workflow_state: "main_people_form") }

    describe "#workflow_state" do
      context ":main_people_form state transitions" do
        context "on next" do
          context "when the registration is a lower tier" do
            subject { build(:new_registration, :lower, workflow_state: "main_people_form") }

            include_examples "has next transition", next_state: "contact_name_form"
          end

          include_examples "has next transition", next_state: "declare_convictions_form"
        end

        context "on back" do
          context "when the registered address was manually entered" do
            let(:registered_address) { build(:address, :registered, :manual_foreign) }
            subject { build(:new_registration, workflow_state: "main_people_form", registered_address: registered_address) }

            include_examples "has back transition", previous_state: "company_address_manual_form"
          end

          include_examples "has back transition", previous_state: "company_address_form"
        end
      end
    end
  end
end
