# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    subject { build(:new_registration, workflow_state: "company_name_form") }

    describe "#workflow_state" do
      context ":company_name_form state transitions" do
        context "on next" do
          context "when the business is based overseas" do
            subject { build(:new_registration, workflow_state: "company_name_form", location: "overseas") }

            include_examples "has next transition", next_state: "company_address_manual_form"
          end

          include_examples "has next transition", next_state: "company_postcode_form"
        end
      end
    end
  end
end
