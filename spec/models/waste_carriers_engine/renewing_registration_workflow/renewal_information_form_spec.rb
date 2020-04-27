# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewingRegistration, type: :model do
    subject do
      build(:renewing_registration,
            :has_required_data,
            business_type: business_type,
            location: location,
            workflow_state: "renewal_information_form")
    end
    let(:business_type) {}
    let(:location) { "england" }

    describe "#workflow_state" do
      context ":renewal_information_form state transitions" do
        context "on next" do
          context "when the business type is localAuthority" do
            let(:business_type) { "localAuthority" }

            include_examples "has next transition", next_state: "company_name_form"
          end

          context "when the business type is limitedCompany" do
            let(:business_type) { "limitedCompany" }

            include_examples "has next transition", next_state: "registration_number_form"
          end

          context "when the business type is limitedLiabilityPartnership" do
            let(:business_type) { "limitedLiabilityPartnership" }

            include_examples "has next transition", next_state: "registration_number_form"
          end

          context "when the location is overseas" do
            let(:location) { "overseas" }

            include_examples "has next transition", next_state: "company_name_form"
          end

          context "when the business type is partnership" do
            let(:business_type) { "partnership" }

            include_examples "has next transition", next_state: "company_name_form"
          end

          context "when the business type is soleTrader" do
            let(:business_type) { "soleTrader" }

            include_examples "has next transition", next_state: "company_name_form"
          end
        end

        context "on back" do
          include_examples "has back transition", previous_state: "cbd_type_form"
        end
      end
    end
  end
end
