# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "LocationForms" do
    it_behaves_like "GET flexible form", "location_form"

    describe "POST location_form_path" do
      it_behaves_like "POST renewal form",
                      "location_form",
                      valid_params: { location: "england" },
                      invalid_params: { location: "foo" },
                      test_attribute: :location

      context "when the transient_registration is a new registration" do
        let(:transient_registration) do
          create(:new_registration, workflow_state: "location_form")
        end

        it_behaves_like "POST form",
                        "location_form",
                        valid_params: { location: "england" },
                        invalid_params: { location: "foo" }

        # When the user starts with a UK company type and then navigates back and changes the location to non-UK
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

          context "when the location is no longer in the UK" do
            it "removes the company attributes" do
              post_form_with_params("location_form", transient_registration.token, { location: "overseas" })
              transient_registration.reload
              expect(transient_registration.company_no).to be_nil
              expect(transient_registration.registered_company_name).to be_nil
              expect(transient_registration.temp_use_registered_company_details).to be_nil
            end
          end
        end
      end
    end
  end
end
