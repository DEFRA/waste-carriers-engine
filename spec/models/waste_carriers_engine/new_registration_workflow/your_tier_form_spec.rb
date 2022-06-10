# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    subject { build(:new_registration, workflow_state: "your_tier_form", temp_check_your_tier: "unknown") }

    describe "#workflow_state" do
      context ":your_tier_form state transitions" do
        context "on next" do

          let(:business_type) { %i[charity limitedCompany limitedLiabilityPartnership localAuthority partnership soleTrader].sample }

          subject { build(:new_registration, business_type: business_type, tier: tier, location: location, workflow_state: "your_tier_form") }

          context "when the registration is a lower tier registration" do
            let(:tier) { WasteCarriersEngine::Registration::LOWER_TIER }

            context "based in England" do
              let(:location) { "England" }

              include_examples "has next transition", next_state: "company_name_form"
            end

            context "based overseas" do
              let(:location) { "overseas" }

              include_examples "has next transition", next_state: "company_name_form"
            end
          end

          context "when the registration is an upper tier registration" do
            let(:tier) { WasteCarriersEngine::Registration::UPPER_TIER }

            context "for a limited company, limited liability partnership or sole trader" do
              let(:business_type) { %i[limitedCompany limitedLiabilityPartnership soleTrader].sample }

              context "based in England" do
                let(:location) { "England" }

                include_examples "has next transition", next_state: "use_trading_name_form"
              end

              context "based overseas" do
                let(:location) { "overseas" }

                include_examples "has next transition", next_state: "company_name_form"
              end
            end

            context "for a business type other than company or sole trader" do
              let(:business_type) { %i[charity localAuthority partnership].sample }
              let(:tier) { WasteCarriersEngine::Registration::LOWER_TIER }

              context "based in England" do
                let(:location) { "England" }

                include_examples "has next transition", next_state: "company_name_form"
              end

              context "based overseas" do
                let(:location) { "overseas" }

                include_examples "has next transition", next_state: "company_name_form"
              end
            end
          end
        end
      end
    end
  end
end
