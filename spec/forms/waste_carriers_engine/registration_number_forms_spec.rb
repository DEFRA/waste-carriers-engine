# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RegistrationNumberForm, type: :model do
    before do
      allow_any_instance_of(DefraRuby::Validators::CompaniesHouseService).to receive(:status).and_return(:active)
    end

    describe "#submit" do
      context "when the form is valid" do
        let(:registration_number_form) { build(:registration_number_form, :has_required_data) }
        let(:valid_params) { { reg_identifier: registration_number_form.reg_identifier, company_no: "09360070" } }

        it "should submit" do
          expect(registration_number_form.submit(valid_params)).to eq(true)
        end

        context "when the reg_identifier is less than 8 characters" do
          before(:each) { valid_params[:company_no] = "946107" }

          it "should increase the length" do
            registration_number_form.submit(valid_params)
            expect(registration_number_form.company_no).to eq("00946107")
          end

          it "should submit" do
            expect(registration_number_form.submit(valid_params)).to eq(true)
          end
        end
      end

      context "when the form is not valid" do
        let(:registration_number_form) { build(:registration_number_form, :has_required_data) }
        let(:invalid_params) { { reg_identifier: "foo", company_no: "foo" } }

        it "should not submit" do
          expect(registration_number_form.submit(invalid_params)).to eq(false)
        end
      end
    end

    include_examples "validate company_no", :registration_number_form
  end
end
