# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewingRegistration, type: :model do
    subject do
      build(:renewing_registration,
            :has_required_data,
            business_type: business_type,
            location: location,
            tier: tier,
            workflow_state: "company_name_form")
    end
    let(:tier) { WasteCarriersEngine::Registration::UPPER_TIER }
    let(:location) { "england" }
    let(:business_type) { "soleTrader" }

    describe "#workflow_state" do
      context ":company_name_form state transitions" do
        context "on next" do
          include_examples "has next transition", next_state: "company_postcode_form"

          context "when the location is overseas" do
            let(:location) { "overseas" }

            include_examples "has next transition", next_state: "company_address_manual_form"
          end
        end
      end
    end
  end
end
