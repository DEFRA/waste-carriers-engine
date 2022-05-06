# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    let(:business_type) { "limitedCompany" }
    subject { build(:new_registration, business_type: business_type, workflow_state: "main_people_form") }

    describe "#workflow_state" do
      context ":main_people_form state transitions" do
        context "on next" do
          include_examples "has next transition", next_state: "company_name_form"
        end

        context "on back" do
          context "when the business type is limited company" do
            let(:business_type) { "limitedCompany" }

            include_examples "has back transition", previous_state: "check_registered_company_name_form"
          end

          context "when the business type is sole trader" do
            let(:business_type) { "soleTrader" }

            include_examples "has back transition", previous_state: "cbd_type_form"
          end
        end
      end
    end
  end
end
