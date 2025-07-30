# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "BusinessTypeForms" do
    it_behaves_like "GET flexible form", "business_type_form"

    describe "POST business_type_form_path" do
      it_behaves_like "POST renewal form",
                      "business_type_form",
                      valid_params: { business_type: "limitedCompany" },
                      invalid_params: { business_type: "foo" },
                      test_attribute: :business_type

      context "when the transient_registration is a new registration" do
        let(:transient_registration) do
          create(:new_registration, workflow_state: "business_type_form")
        end

        it_behaves_like "POST form",
                        "business_type_form",
                        valid_params: { business_type: "limitedCompany" },
                        invalid_params: { business_type: "foo" }

        # When the user starts with one business type then navigates back and changes the type
        context "when the transient_registration already has company attributes" do
          let(:company_no) { Faker::Number.number(digits: 8).to_s }
          let(:registered_company_name) { Faker::Company.name }
          let(:temp_use_registered_company_details) { "yes" }

          before do
            transient_registration.company_no = company_no
            transient_registration.registered_company_name = registered_company_name
            transient_registration.temp_use_registered_company_details = temp_use_registered_company_details
            transient_registration.save!
          end

          context "when the business type is no longer limitedCompany" do
            it "removes the company attributes" do
              post_form_with_params("business_type_form", transient_registration.token, { business_type: "soleTrader" })
              transient_registration.reload
              expect(transient_registration.company_no).to be_nil
              expect(transient_registration.registered_company_name).to be_nil
              expect(transient_registration.temp_use_registered_company_details).to be_nil
            end
          end

          context "when the business type is still limitedCompany" do
            it "does not remove the company attributes" do
              post_form_with_params("business_type_form", transient_registration.token, { business_type: "limitedCompany" })
              transient_registration.reload
              expect(transient_registration.company_no).to eq(company_no)
              expect(transient_registration.registered_company_name).to eq(registered_company_name)
              expect(transient_registration.temp_use_registered_company_details).to eq(temp_use_registered_company_details)
            end
          end
        end
      end
    end
  end
end
