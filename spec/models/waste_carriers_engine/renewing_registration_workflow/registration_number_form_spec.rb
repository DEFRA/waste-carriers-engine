# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewingRegistration, type: :model do
    describe "#workflow_state" do
      subject do
        build(:renewing_registration,
              :has_required_data,
              workflow_state: "registration_number_form")
      end

      context ":registration_number_form state transitions" do
        context "on next" do
          include_examples "has next transition", next_state: "company_name_form"

          context "when the company_no has changed" do
            before { subject.company_no = "01234567" }

            include_examples "has next transition", next_state: "cannot_renew_company_no_change_form"

            context "when the business used to be a partnership and is now an LLP" do
              before do
                subject.business_type = "limitedLiabilityPartnership"
                subject.registration.update_attributes(business_type: "partnership")
              end

              include_examples "has next transition", next_state: "company_name_form"
            end
          end

          context "when the old company_no had trailing whitespace in it" do
            before do
              subject.registration.update_attributes(company_no: "#{subject.company_no} ")
            end

            include_examples "has next transition", next_state: "company_name_form"
          end
        end

        context "on back" do
          include_examples "has back transition", previous_state: "renewal_information_form"
        end
      end
    end

    describe "validating the company_no" do
      let(:validator) { double(:validator, :validate_each) }
      let!(:registration_number_form) { build(:registration_number_form, :has_required_data) }

      before do
        allow(registration_number_form)
          .to receive(:business_type)
          .and_return(business_type)
      end

      context "when the registration is for a limitedLiabilityPartnership" do
        let(:business_type) { "limitedLiabilityPartnership" }

        before do
          expect_any_instance_of(DefraRuby::Validators::CompaniesHouseNumberValidator)
            .to receive(:validate_each)
            .with(registration_number_form, :company_no, registration_number_form.company_no)
        end

        it "invokes the validator" do
          registration_number_form.valid?
        end
      end

      context "when the registration is for a limitedCompany" do
        let(:business_type) { "limitedCompany" }

        before do
          expect_any_instance_of(DefraRuby::Validators::CompaniesHouseNumberValidator)
            .to receive(:validate_each)
            .with(registration_number_form, :company_no, registration_number_form.company_no)
        end

        it "invokes the validator" do
          registration_number_form.valid?
        end
      end

      context "when the registration is for somethingElse" do
        let(:business_type) { "somethingElse" }

        before do
          expect_any_instance_of(DefraRuby::Validators::CompaniesHouseNumberValidator)
            .not_to receive(:validate_each)
        end

        it "does not invoke the validator" do
          registration_number_form.valid?
        end
      end
    end
  end
end
