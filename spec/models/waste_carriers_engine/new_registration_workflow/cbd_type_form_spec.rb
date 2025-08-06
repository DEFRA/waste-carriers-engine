# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    subject { build(:new_registration, workflow_state: "cbd_type_form") }

    describe "#workflow_state" do
      context "with :cbd_type_form state transitions" do
        context "with :next transition" do
          context "when a company registration number is required" do
            subject { build(:new_registration, workflow_state: "cbd_type_form", business_type: "limitedCompany") }

            it_behaves_like "has next transition", next_state: "registration_number_form"
          end

          it_behaves_like "has next transition", next_state: "main_people_form"
        end
      end
    end
  end
end
