# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do

    all_business_types = %i[charity limitedCompany limitedLiabilityPartnership localAuthority partnership soleTrader].freeze

    subject { build(:new_registration, workflow_state: "your_tier_form", temp_check_your_tier: "unknown") }

    describe "#workflow_state" do
      context "with :your_tier_form state transitions" do
        context "with :next transition" do

          subject { build(:new_registration, business_type: business_type, tier: tier, workflow_state: "your_tier_form") }

          context "when the registration is a lower tier registration" do
            let(:tier) { WasteCarriersEngine::Registration::LOWER_TIER }

            all_business_types.each do |business_type|
              let(:business_type) { business_type }

              it_behaves_like "has next transition", next_state: "company_name_form"
            end
          end

          context "when the registration is an upper tier registration" do
            let(:tier) { WasteCarriersEngine::Registration::UPPER_TIER }

            all_business_types.each do |business_type|
              let(:business_type) { business_type }

              it_behaves_like "has next transition", next_state: "cbd_type_form"
            end
          end
        end
      end
    end
  end
end
