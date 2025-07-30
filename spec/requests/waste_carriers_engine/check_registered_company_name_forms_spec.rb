# frozen_string_literal: true

require "rails_helper"
require "defra_ruby/companies_house"

module WasteCarriersEngine
  RSpec.describe "CheckRegisteredCompanyNameForms" do

    let(:company_name) { Faker::Company.name }
    let(:company_address) { ["10 Downing St", "Horizon House", "Bristol", "BS1 5AH"] }
    let(:companies_house_api) { instance_double(DefraRuby::CompaniesHouse::API) }
    let(:companies_house_api_reponse) do
      {
        company_name:,
        registered_office_address: company_address
      }
    end

    before do
      allow(DefraRuby::CompaniesHouse::API).to receive(:new).and_return(companies_house_api)
      allow(companies_house_api).to receive(:run).and_return(companies_house_api_reponse)
    end

    it_behaves_like "GET flexible form", "check_registered_company_name_form"

    describe "GET check_registered_company_name_form_path" do

      context "when check_registered_company_name_form is given a valid companies house number" do
        let(:transient_registration) do
          create(:new_registration,
                 :has_required_data,
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
            allow(companies_house_api).to receive(:run).and_raise(StandardError)
          end

          it "raises an error" do
            get check_registered_company_name_forms_path(transient_registration[:token])

            expect(response).to render_template("waste_carriers_engine/check_registered_company_name_forms/companies_house_down")
          end
        end
      end
    end

    describe "POST check_registered_company_name_form_path" do
      context "when the transient_registration is a new registration" do
        let(:transient_registration) do
          create(:new_registration, workflow_state: "check_registered_company_name_form")
        end

        it_behaves_like "POST form",
                        "check_registered_company_name_form",
                        valid_params: { temp_use_registered_company_details: "no", company_no: "09360070" },
                        invalid_params: { temp_use_registered_company_details: "foo", company_no: "09360070" }
      end
    end
  end
end
