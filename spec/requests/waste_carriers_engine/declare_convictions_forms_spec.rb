require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "DeclareConvictionsForms", type: :request do
    include_examples "GET flexible form", form = "declare_convictions_form"

    include_examples "POST form",
                     form = "declare_convictions_form",
                     valid_params = { declared_convictions: "yes" },
                     invalid_params = { declared_convictions: "foo" },
                     test_attribute = :declared_convictions

    describe "GET back_declare_convictions_forms_path" do
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
                   workflow_state: "declare_convictions_form")
          end

          context "when the back action is triggered" do
            it "returns a 302 response" do
              get back_declare_convictions_forms_path(transient_registration[:reg_identifier])
              expect(response).to have_http_status(302)
            end

            it "redirects to the main_people form" do
              get back_declare_convictions_forms_path(transient_registration[:reg_identifier])
              expect(response).to redirect_to(new_main_people_form_path(transient_registration[:reg_identifier]))
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
              get back_declare_convictions_forms_path(transient_registration[:reg_identifier])
              expect(response).to have_http_status(302)
            end

            it "redirects to the correct form for the state" do
              get back_declare_convictions_forms_path(transient_registration[:reg_identifier])
              expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
            end
          end
        end
      end
    end
  end
end
