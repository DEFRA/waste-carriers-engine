# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewingRegistration, type: :model do
    subject do
      build(:renewing_registration,
            :has_required_data,
            business_type: business_type,
            location: location,
            workflow_state: "company_name_form")
    end
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

        context "on back" do
          context "when the business type is localAuthority" do
            let(:business_type) { "localAuthority" }

            include_examples "has back transition", previous_state: "renewal_information_form"
          end

          context "when the business type is limitedCompany" do
            let(:business_type) { "limitedCompany" }

            include_examples "has back transition", previous_state: "check_registered_company_name_form"
          end

          context "when the business type is limitedLiabilityPartnership" do
            let(:business_type) { "limitedLiabilityPartnership" }

            include_examples "has back transition", previous_state: "check_registered_company_name_form"
          end

          context "when the business type is partnership" do
            let(:business_type) { "partnership" }

            include_examples "has back transition", previous_state: "renewal_information_form"
          end

          context "when the business type is soleTrader" do
            let(:business_type) { "soleTrader" }

            include_examples "has back transition", previous_state: "renewal_information_form"
          end

          context "when the location is overseas" do
            let(:location) { "overseas" }

            include_examples "has back transition", previous_state: "renewal_information_form"
          end
        end
      end
    end
  end
end
