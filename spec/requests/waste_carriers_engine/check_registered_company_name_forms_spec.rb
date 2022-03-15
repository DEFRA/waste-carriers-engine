# frozen_string_literal: true

require "rails_helper"
require "defra_ruby_companies_house"

module WasteCarriersEngine
  RSpec.describe "CheckRegisteredCompanyNameForms", type: :request do

    let(:company_name) { Faker::Company.name }
    let(:company_address) { ["10 Downing St", "Horizon House", "Bristol", "BS1 5AH"] }

    before do
      allow_any_instance_of(DefraRubyCompaniesHouse).to receive(:load_company)
      allow_any_instance_of(DefraRubyCompaniesHouse).to receive(:company_name).and_return(company_name)
      allow_any_instance_of(DefraRubyCompaniesHouse).to receive(:registered_office_address_lines).and_return(company_address)
    end

    include_examples "GET flexible form", "check_registered_company_name_form"

    describe "GET check_registered_company_name_form_path" do
      context "when a valid user is signed in" do
        let(:user) { create(:user) }
        before(:each) do
          sign_in(user)
        end

        context "when check_registered_companys_name_form is given a valid companys house number" do
          let(:transient_registration) do
            create(:new_registration,
                   :has_required_data,
                   account_email: user.email,
                   workflow_state: "check_registered_company_name_form")
          end

          it "displays the registered company name" do
            get check_registered_company_name_forms_path(transient_registration[:token])
            expect(response.body).to include(company_name)
          end

          it "displays the registered company address" do
            get check_registered_company_name_forms_path(transient_registration[:token])

            company_address.each do |line|
              expect(response.body).to include(line)
            end
          end
        end
      end
    end

    describe "GET back_check_registered_company_name_form_path" do
      context "when a valid user is signed in" do
        let(:user) { create(:user) }
        before(:each) do
          sign_in(user)
        end

        context "when a valid transient registration exists" do
          let(:transient_registration) do
            create(:new_registration,
                   :has_required_data,
                   account_email: user.email,
                   workflow_state: "check_registered_company_name_form")
          end

          context "when the back action is triggered" do
            it "returns a 302 response and redirects to the registration_number_form" do
              get back_check_registered_company_name_forms_path(transient_registration[:token])

              expect(response).to have_http_status(302)
              expect(response).to redirect_to(registration_number_forms_path(transient_registration[:token]))
            end
          end
        end
      end
    end
  end
end
