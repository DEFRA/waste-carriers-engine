# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewingRegistration, type: :model do
    subject do
      build(:renewing_registration,
            :has_required_data,
            addresses: addresses,
            workflow_state: "main_people_form")
    end
    let(:addresses) { [] }

    describe "#workflow_state" do
      context ":main_people_form state transitions" do
        context "on next" do
          include_examples "has next transition", next_state: "company_postcode_form"
        end

        context "on back" do
          include_examples "has back transition", previous_state: "company_name_form"
        end
      end
    end
  end
end
