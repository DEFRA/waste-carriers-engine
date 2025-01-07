# frozen_string_literal: true

require "rails_helper"
require "defra_ruby/companies_house"

module WasteCarriersEngine
  RSpec.describe RenewingRegistration do
    subject do
      build(:renewing_registration,
            :has_required_data,
            business_type: business_type,
            location: location,
            tier: tier,
            company_no: company_number,
            workflow_state: "renewal_information_form")
    end
    let(:tier) { WasteCarriersEngine::Registration::UPPER_TIER }
    let(:business_type) { nil }
    let(:location) { "england" }
    let(:companies_house_api) { instance_double(DefraRuby::CompaniesHouse::API) }
    let(:companies_house_api_reponse) do
      {
        company_status:
      }
    end

    let(:company_status) { "active" }
    let(:company_number) { "12345678" }

    before do
      allow(DefraRuby::CompaniesHouse::API).to receive(:new).and_return(companies_house_api)
      allow(companies_house_api).to receive(:run).and_return(companies_house_api_reponse)
    end

    describe "#workflow_state" do
      context "with :renewal_information_form state transitions" do
        context "with :next transition" do

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

          shared_examples "check_registered_company_name_form or invalid_company_status_form" do

            %w[active
               voluntary-arrangement].each do |status|
              context "with a company status of #{status}" do
                let(:company_status) { status }

                include_examples "has next transition", next_state: "check_registered_company_name_form"
              end
            end

            %w[dissolved
               liquidation
               receivership
               administration
               converted-closed
               insolvency-proceedings
               registered
               removed
               closed
               open].each do |status|
              context "with a company status of #{status}" do
                let(:company_status) { status }

                include_examples "has next transition", next_state: "invalid_company_status_form"
              end
            end
          end

          context "when the business type is limitedCompany" do
            let(:business_type) { "limitedCompany" }

            include_examples "check_registered_company_name_form or invalid_company_status_form"
          end

          context "when the business type is limitedLiabilityPartnership" do
            let(:business_type) { "limitedLiabilityPartnership" }

            include_examples "check_registered_company_name_form or invalid_company_status_form"
          end

          context "when the business is overseas" do
            let(:location) { "overseas" }
            let(:business_type) { "overseas" }
            let(:company_number) { "invalid" }

            include_examples "has next transition", next_state: "main_people_form"
          end

          context "when Companies House Api returns an error" do
            before do
              allow(companies_house_api).to receive(:run).and_raise(StandardError)
            end

            context "when the business type is limitedCompany with non-UK company number" do
              let(:business_type) { "limitedCompany" }

              include_examples "has next transition", next_state: "invalid_company_status_form"
            end

            context "when the business type is limitedLiabilityPartnership with non-UK company number" do
              let(:business_type) { "limitedLiabilityPartnership" }

              include_examples "has next transition", next_state: "invalid_company_status_form"
            end
          end
        end
      end
    end
  end
end
