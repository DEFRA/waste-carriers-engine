require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "ConstructionDemolitionForms", type: :request do
    include_examples "GET flexible form", form = "construction_demolition_form"

    include_examples "POST form",
                     form = "construction_demolition_form",
                     valid_params = { construction_waste: "yes" },
                     invalid_params = { construction_waste: "foo" },
                     test_attribute = :construction_waste

    describe "GET back_construction_demolition_forms_path" do
      context "when a valid user is signed in" do
        let(:user) { create(:user) }
        before(:each) do
          sign_in(user)
        end

        context "when a valid transient registration exists" do
          let(:transient_registration) do
            create(:transient_registration,
                   :has_required_data,
                   account_email: user.email,
                   workflow_state: "construction_demolition_form")
          end

          context "when the back action is triggered" do
            it "returns a 302 response" do
              get back_construction_demolition_forms_path(transient_registration[:reg_identifier])
              expect(response).to have_http_status(302)
            end

            context "when the business does not carry waste for other businesses or households" do
              before(:each) { transient_registration.update_attributes(other_businesses: "no") }

              it "redirects to the other_businesses form" do
                get back_construction_demolition_forms_path(transient_registration[:reg_identifier])
                expect(response).to redirect_to(new_other_businesses_form_path(transient_registration[:reg_identifier]))
              end
            end

            context "when the business does carry waste for other businesses or households" do
              before(:each) { transient_registration.update_attributes(other_businesses: "yes") }

              it "redirects to the service_provided form" do
                get back_construction_demolition_forms_path(transient_registration[:reg_identifier])
                expect(response).to redirect_to(new_service_provided_form_path(transient_registration[:reg_identifier]))
              end
            end
          end
        end

        context "when the transient registration is in the wrong state" do
          let(:transient_registration) do
            create(:transient_registration,
                   :has_required_data,
                   account_email: user.email,
                   workflow_state: "renewal_start_form")
          end

          context "when the back action is triggered" do
            it "returns a 302 response" do
              get back_construction_demolition_forms_path(transient_registration[:reg_identifier])
              expect(response).to have_http_status(302)
            end

            it "redirects to the correct form for the state" do
              get back_construction_demolition_forms_path(transient_registration[:reg_identifier])
              expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
            end
          end
        end
      end
    end
  end
end
