# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "DeclarationForms", type: :request do
    before do
      allow_any_instance_of(RestClient::Request).to receive(:execute).and_return("foo")
    end

    include_examples "GET locked-in form", "declaration_form"

    describe "POST declaration_form_path" do
      include_examples "POST renewal form",
                       "declaration_form",
                       valid_params: { declaration: 1 },
                       invalid_params: { declaration: "foo" },
                       test_attribute: :declaration

      context "When the transient_registration is a new registration" do
        let(:transient_registration) do
          create(:new_registration, workflow_state: "declaration_form")
        end

        include_examples "POST form",
                         "declaration_form",
                         valid_params: { declaration: 1 },
                         invalid_params: { declaration: "foo" }
      end
    end

    describe "POST declaration_forms_path" do
      context "when a valid user is signed in" do
        let(:user) { create(:user) }
        before(:each) do
          sign_in(user)
        end

        context "when a valid transient registration exists" do
          let!(:transient_registration) do
            create(:renewing_registration,
                   :has_required_data,
                   :has_key_people,
                   account_email: user.email,
                   workflow_state: "declaration_form")
          end

          let(:params) { { declaration: 1 } }

          it "creates new conviction_search_results for the registration and key people" do
            post_form_with_params("declaration_form", transient_registration.token, params)

            expect(transient_registration.reload.conviction_search_result).to_not eq(nil)
            expect(transient_registration.reload.key_people.first.conviction_search_result).to_not eq(nil)
          end
        end
      end
    end

    describe "GET back_declaration_forms_path" do
      context "when a valid user is signed in" do
        let(:user) { create(:user) }
        before(:each) do
          sign_in(user)
        end

        context "when a valid transient registration exists" do
          let(:transient_registration) do
            create(:renewing_registration,
                   :has_required_data,
                   account_email: user.email,
                   workflow_state: "declaration_form")
          end

          context "when the back action is triggered" do
            it "returns a 302 response and redirects to the check_your_answers form" do
              get back_declaration_forms_path(transient_registration[:token])

              expect(response).to have_http_status(302)
              expect(response).to redirect_to(new_check_your_answers_form_path(transient_registration[:token]))
            end
          end
        end

        context "when the transient registration is in the wrong state" do
          let(:transient_registration) do
            create(:renewing_registration,
                   :has_required_data,
                   account_email: user.email,
                   workflow_state: "renewal_start_form")
          end

          context "when the back action is triggered" do
            it "returns a 302 response and redirects to the correct form for the state" do
              get back_declaration_forms_path(transient_registration[:token])

              expect(response).to have_http_status(302)
              expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:token]))
            end
          end
        end
      end
    end
  end
end
