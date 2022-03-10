# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "CheckRegisteredCompanyNameForms", type: :request do
    include_examples "GET flexible form", "check_registered_company_name_form"

    describe "POST check_registered_company_name_form_path" do
<<<<<<< HEAD
      context "when a valid user is signed in" do
        let(:user) { create(:user) }
        before(:each) do
          sign_in(user)
        end
      end

=======
      context "when a valid user is signed in" do 
        let(:user) { create(:user) }
          before(:each) do
            sign_in(:user)
          end
      end 
      
>>>>>>> e1ffe1b85504a512f6f428914583e1fdc7e8a7fb
      context "When the transient_registration is a new registration" do
        let(:transient_registration) do
          create(:new_registration, workflow_state: "check_registered_company_name_form")
        end

        include_examples "POST form",
                         "check_registered_company_name_form",
                         valid_params: { temp_use_registered_company_details: "yes" },
                         invalid_params: { temp_use_registered_company_details: "foo" }
<<<<<<< HEAD
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
=======
>>>>>>> e1ffe1b85504a512f6f428914583e1fdc7e8a7fb
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

        context "when the transient registration is in the wrong state" do 

        end
      end 
    end
  end
end
