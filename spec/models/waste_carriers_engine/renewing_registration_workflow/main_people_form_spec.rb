# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewingRegistration, type: :model do
    subject do
      build(:renewing_registration,
            :has_required_data,
            addresses: addresses,
            business_type: business_type,
            workflow_state: "main_people_form")
    end
    let(:business_type) { "soleTrader" }
    let(:addresses) { [] }

    describe "#workflow_state" do
      context ":main_people_form state transitions" do
        context "on next" do
          include_examples "has next transition", next_state: "company_name_form"
        end
      end
    end
  end
end
