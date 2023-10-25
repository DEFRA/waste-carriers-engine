# frozen_string_literal: true

require "rails_helper"
require "defra_ruby_companies_house"

module WasteCarriersEngine
  RSpec.describe "CheckRegisteredCompanyNameForms" do

    let(:company_name) { Faker::Company.name }
    let(:company_address) { ["10 Downing St", "Horizon House", "Bristol", "BS1 5AH"] }
    let(:companies_house_service) { instance_double(DefraRubyCompaniesHouse) }

    before do
      allow(DefraRubyCompaniesHouse).to receive(:new).and_return(companies_house_service)
      allow(companies_house_service).to receive(:company_name).and_return(company_name)
      allow(companies_house_service).to receive(:registered_office_address_lines).and_return(company_address)
    end

    include_examples "GET flexible form", "check_registered_company_name_form"

    describe "GET check_registered_company_name_form_path" do
      context "when a valid user is signed in" do
        let(:user) { create(:user) }

        before do
          sign_in(user)
        end

        context "when check_registered_company_name_form is given a valid companies house number" do
          let(:transient_registration) do
            create(:new_registration,
                   :has_required_data,
                   account_email: user.email,
                   workflow_state: "check_registered_company_name_form")
          end

          it "displays the registered company name" do
            get check_registered_company_name_forms_path(transient_registration[:token])
            expect(CGI.unescapeHTML(response.body)).to include(company_name)
          end

          it "displays the registered company address" do
            get check_registered_company_name_forms_path(transient_registration[:token])

            company_address.each do |line|
              expect(response.body).to include(line)
            end
          end

          context "when the company house API is down" do
            before do
              allow(companies_house_service).to receive(:company_name).and_raise(StandardError)
            end

            it "raises an error" do
              get check_registered_company_name_forms_path(transient_registration[:token])

              expect(response).to render_template("waste_carriers_engine/check_registered_company_name_forms/companies_house_down")
            end
          end
        end
      end
    end

    describe "POST check_registered_company_name_form_path" do
      context "when the transient_registration is a new registration" do
        let(:transient_registration) do
          create(:new_registration, workflow_state: "check_registered_company_name_form")
        end

        include_examples "POST form",
                         "check_registered_company_name_form",
                         valid_params: { temp_use_registered_company_details: "no", company_no: "09360070" },
                         invalid_params: { temp_use_registered_company_details: "foo", company_no: "09360070" }
      end
    end
  end
end
