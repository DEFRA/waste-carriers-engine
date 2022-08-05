# frozen_string_literal: true

require "rails_helper"
require "defra_ruby_companies_house"

module WasteCarriersEngine
  RSpec.describe CheckRegisteredCompanyNameForm, type: :model do
    let(:registered_company_name) { Faker::Company.name }
    let(:company_address) { ["10 Downing St", "Horizon House", "Bristol", "BS1 5AH"] }

    before do
      allow_any_instance_of(DefraRubyCompaniesHouse).to receive(:load_company).and_return(true)
      allow_any_instance_of(DefraRubyCompaniesHouse).to receive(:company_name).and_return(registered_company_name)
      allow_any_instance_of(DefraRubyCompaniesHouse).to receive(:registered_office_address_lines).and_return(company_address)
    end

    describe "#submit" do
      let(:check_registered_company_name_form) { build(:check_registered_company_name_form, :new_registration, :has_required_data) }

      context "when the form is valid" do
        subject { check_registered_company_name_form.submit(valid_params) }

        context "when the user selects yes to the company house details being correct" do
          let(:valid_params) { { token: check_registered_company_name_form.token, temp_use_registered_company_details: "yes" } }
          let(:transient_registration) { check_registered_company_name_form.transient_registration }

          it "should submit" do
            expect(subject).to be_truthy
          end

          context "for a new registration" do
            it "should update the transient registration" do
              expect { subject }.to change { transient_registration.reload.attributes["registeredCompanyName"] }.to(registered_company_name)
            end
          end

          context "for a registration renewal" do
            let(:check_registered_company_name_form) { build(:check_registered_company_name_form, :renewing_registration, :has_required_data) }

            it "should update the transient registration" do
              expect { subject }.to change { transient_registration.reload.attributes["registeredCompanyName"] }.to(registered_company_name)
            end

            context "when the existing registration does not have a registered company name" do
              before { transient_registration.registered_company_name = nil }
              it "clears the company_name value" do
                expect { subject }.to change { transient_registration.reload.attributes["companyName"] }.to(nil)
              end
            end

            context "when the existing registration has a registered company name" do
              before { transient_registration.registered_company_name = Faker::Company.name }
              it "clears the company_name value" do
                expect { subject }.to change { transient_registration.reload.attributes["companyName"] }.to(nil)
              end
            end
          end
        end

        context "when the user selects no to the company house details being correct" do
          let(:valid_params) { { token: check_registered_company_name_form.token, temp_use_registered_company_details: "no" } }

          it "should submit" do
            expect(subject).to be_truthy
          end
        end
      end

      context "when the form is not valid" do
        before do
          expect(check_registered_company_name_form).to receive(:valid?).and_return(false)
        end

        it "should not submit" do
          expect(check_registered_company_name_form.submit({})).to be_falsey
        end
      end
    end

    include_examples "validate yes no", :check_registered_company_name_form, :temp_use_registered_company_details
  end
end
