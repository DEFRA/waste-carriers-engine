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
            workflow_state: "renewal_information_form")
    end
    let(:tier) { WasteCarriersEngine::Registration::UPPER_TIER }
    let(:business_type) {}
    let(:location) { "england" }

    describe "#workflow_state" do
      context ":renewal_information_form state transitions" do
        context "on next" do

          shared_examples "main_people_form or company_name_form based on tier" do
            context "when upper tier" do
              let(:tier) { WasteCarriersEngine::Registration::UPPER_TIER }
              include_examples "has next transition", next_state: "main_people_form"
            end

            context "when lower tier" do
              let(:tier) { WasteCarriersEngine::Registration::LOWER_TIER }
              include_examples "has next transition", next_state: "company_name_form"
            end
          end

          context "when the location is overseas" do
            let(:location) { "overseas" }

            it_behaves_like "main_people_form or company_name_form based on tier"
          end

          context "when the business type is localAuthority" do
            let(:business_type) { "localAuthority" }

            it_behaves_like "main_people_form or company_name_form based on tier"
          end

          context "when the business type is partnership" do
            let(:business_type) { "partnership" }

            it_behaves_like "main_people_form or company_name_form based on tier"
          end

          context "when the business type is soleTrader" do
            let(:business_type) { "soleTrader" }

            it_behaves_like "main_people_form or company_name_form based on tier"
          end

          context "when the business type is limitedCompany" do
            let(:business_type) { "limitedCompany" }

            include_examples "has next transition", next_state: "check_registered_company_name_form"
          end

          context "when the business type is limitedLiabilityPartnership" do
            let(:business_type) { "limitedLiabilityPartnership" }

            include_examples "has next transition", next_state: "check_registered_company_name_form"
          end
        end
      end
    end
  end
end
