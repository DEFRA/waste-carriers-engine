# frozen_string_literal: true

require "rails_helper"
require "defra_ruby/companies_house"

module WasteCarriersEngine
  RSpec.describe CheckRegisteredCompanyNameForm do
    let(:registered_company_name) { Faker::Company.name }
    let(:company_address) { ["10 Downing St", "Horizon House", "Bristol", "BS1 5AH"] }
    let(:companies_house_api) { instance_double(DefraRuby::CompaniesHouse::API) }
    let(:companies_house_api_response) do
      {
        company_name: registered_company_name,
        registered_office_address: company_address
      }
    end

    before do
      allow(DefraRuby::CompaniesHouse::API).to receive(:new).and_return(companies_house_api)
      allow(companies_house_api).to receive(:run).and_return(companies_house_api_response)
    end

    describe "#submit" do
      let(:check_registered_company_name_form) { build(:check_registered_company_name_form, :new_registration, :has_required_data) }

      context "when the form is valid" do
        subject(:form_submit) { check_registered_company_name_form.submit(valid_params) }

        context "when the user selects yes to the company house details being correct" do
          let(:valid_params) { { token: check_registered_company_name_form.token, temp_use_registered_company_details: "yes" } }
          let(:transient_registration) { check_registered_company_name_form.transient_registration }

          it "submits" do
            expect(form_submit).to be_truthy
          end

          context "with a new registration" do
            it "updates the transient registration" do
              expect { form_submit }.to change { transient_registration.reload.attributes["registeredCompanyName"] }.to(registered_company_name)
            end
          end

          context "with a registration renewal" do
            let(:check_registered_company_name_form) { build(:check_registered_company_name_form, :renewing_registration, :has_required_data) }

            it "updates the transient registration" do
              expect { form_submit }.to change { transient_registration.reload.attributes["registeredCompanyName"] }.to(registered_company_name)
            end

            context "when the existing registration does not have a registered company name" do
              before { transient_registration.registered_company_name = nil }

              it "clears the company_name value" do
                expect { form_submit }.to change { transient_registration.reload.attributes["companyName"] }.to(nil)
              end
            end

            context "when the existing registration has a registered company name" do
              before { transient_registration.registered_company_name = Faker::Company.name }

              it "clears the company_name value" do
                expect { form_submit }.to change { transient_registration.reload.attributes["companyName"] }.to(nil)
              end
            end
          end
        end

        context "when the user selects no to the company house details being correct" do
          let(:valid_params) { { token: check_registered_company_name_form.token, temp_use_registered_company_details: "no" } }

          it "submits" do
            expect(form_submit).to be_truthy
          end
        end
      end

      context "when the form is not valid" do
        before do
          allow(check_registered_company_name_form).to receive(:valid?).and_return(false)
        end

        it "does not submit" do
          expect(check_registered_company_name_form.submit({})).to be_falsey
        end
      end
    end

    it_behaves_like "validate yes no", :check_registered_company_name_form, :temp_use_registered_company_details
  end
end
