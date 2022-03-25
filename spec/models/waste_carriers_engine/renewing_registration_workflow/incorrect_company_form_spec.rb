# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewingRegistration, type: :model do
    subject do
      build(:renewing_registration, :has_required_data, workflow_state: "incorrect_company_form")
    end

    describe "#workflow_state" do
      context ":incorrect_company_form state transitions" do
        context "on back" do
          include_examples "has back transition", previous_state: "check_registered_company_name_form"
        end
      end
    end
  end
end
