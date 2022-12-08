# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RegistrationNumberForm, type: :model do
    let(:companies_house_validator) { instance_double(DefraRuby::Validators::CompaniesHouseService) }

    before do
      allow(DefraRuby::Validators::CompaniesHouseService).to receive(:new).and_return(companies_house_validator)
      allow(companies_house_validator).to receive(:status).and_return(:active)
    end

    describe "#submit" do
      context "when the form is valid" do
        let(:registration_number_form) { build(:registration_number_form, :has_required_data) }
        let(:valid_params) { { token: registration_number_form.token, company_no: "09360070" } }

        it "submits" do
          expect(registration_number_form.submit(valid_params)).to be true
        end

        context "when the company number contains lower case characters" do
          before { valid_params[:company_no] = "az016107" }

          it "saves as upper case" do
            registration_number_form.submit(valid_params)
            expect(registration_number_form.company_no).to eq("AZ016107")
          end

          it "submits" do
            expect(registration_number_form.submit(valid_params)).to be true
          end
        end

        context "when the company number is less than 8 characters" do
          before { valid_params[:company_no] = "946107" }

          it "increases the length before saving" do
            registration_number_form.submit(valid_params)
            expect(registration_number_form.company_no).to eq("00946107")
          end

          it "submits" do
            expect(registration_number_form.submit(valid_params)).to be true
          end
        end
      end

      context "when the form is not valid" do
        let(:registration_number_form) { build(:registration_number_form, :has_required_data) }
        let(:invalid_params) { { token: "foo", company_no: "foo" } }

        it "does not submit" do
          expect(registration_number_form.submit(invalid_params)).to be false
        end
      end
    end

    it "validates the company_no using the CompaniesHouseNumberValidator class" do
      validators = build(:registration_number_form, :has_required_data)._validators
      expect(validators.keys).to include(:company_no)
      expect(validators[:company_no].first.class)
        .to eq(DefraRuby::Validators::CompaniesHouseNumberValidator)
    end
  end
end
