# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "BusinessTypeForms", type: :request do
    describe "GET back_business_type_forms_path" do
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
                   workflow_state: "business_type_form")
          end

          context "when the back action is triggered" do
            it "returns a 302 response and redirects to the location form" do
              get back_business_type_forms_path(transient_registration[:reg_identifier])

              expect(response).to have_http_status(302)
              expect(response).to redirect_to(new_location_form_path(transient_registration[:reg_identifier]))
            end
          end
        end

        context "when the transient registration is in the wrong state" do
          let(:transient_registration) do
            create(:renewing_registration,
                   :has_required_data,
                   account_email: user.email,
                   workflow_state: "location_form")
          end

          context "when the back action is triggered" do
            it "returns a 302 response and redirects to the correct form for the state" do
              get back_business_type_forms_path(transient_registration[:reg_identifier])

              expect(response).to have_http_status(302)
              expect(response).to redirect_to(new_location_form_path(transient_registration[:reg_identifier]))
            end
          end
        end
      end

      # TODO: Consider sharerd scenario for this only
      context "when no user is signed in" do
        it "redirects to the login page" do
          get back_business_type_forms_path(:reg_identifier)

          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end

    describe "GET new_business_type_form_path" do
      context "when a valid user is signed in" do
        # TODISCUSS: Consider adding a shared context for those setups for valid user login.
        # Shared context is different from shared scenario.
        # Example: https://engineering.tripping.com/using-rspec-shared-examples-for-reusable-ruby-tests-d1523538599b
        let(:user) { create(:user) }

        before(:each) do
          sign_in(user)
        end

        context "when no renewal is in progress" do
          let(:registration) do
            create(
              :registration,
              :has_required_data,
              :expires_soon,
              account_email: user.email
            )
          end

          it "redirects to the renewal_start_form" do
            get new_business_type_form_path(registration[:reg_identifier])

            expect(response).to redirect_to(new_renewal_start_form_path(registration[:reg_identifier]))
          end

          # TODISCUSS: Consider shared scenario?
          context "when the linked registration does not belongs to the logged in user" do
            let(:registration) do
              create(
                :registration,
                :has_required_data,
                :expires_soon
              )
            end

            it "redirects to account permission page" do
              get new_business_type_form_path(registration[:reg_identifier])

              expect(response).to redirect_to(page_path(:permission))
            end
          end
        end

        context "when a renewal is in progress" do
          let(:transient_registration) do
            create(:transient_registration,
                   :has_required_data,
                   account_email: user.email,
                   workflow_state: workflow_state)
          end

          context "when the workflow_state matches the request" do
            let(:workflow_state) { "business_type_form" }

            it "loads the requested page" do
              get new_business_type_form_path(transient_registration[:reg_identifier])

              expect(response).to render_template("business_type_forms/new")
            end
          end

          context "when the workflow_state is a flexible form" do
            let(:workflow_state) { "waste_types_form" }

            it "updates the workflow_state to match the requested page and load the correct page" do
              get new_business_type_form_path(transient_registration[:reg_identifier])

              expect(transient_registration.reload[:workflow_state]).to eq("business_type_form")
              expect(response).to render_template("business_type_forms/new")
            end
          end

          # Once users are in a locked-in workflow state, for example, the end of the journey,
          # we don't want them to be able to skip back to an earlier page any more.
          context "when the workflow_state is a locked-in form" do
            let(:workflow_state) { "payment_summary_form" }

            it "redirects to the saved workflow_state and do not update the the " do
              get new_business_type_form_path(transient_registration[:reg_identifier])

              expect(response).to redirect_to(new_payment_summary_form_path(transient_registration[:reg_identifier]))
              expect(transient_registration.reload[:workflow_state]).to eq(workflow_state)
            end
          end

          # TODISCUSS: Consider shared scenario?
          context "when the transient registration does not belongs to the logged in user" do
            let(:transient_registration) do
              create(
                :transient_registration,
                :has_required_data
              )
            end

            it "redirects to account permission page" do
              get new_business_type_form_path(transient_registration[:reg_identifier])

              expect(response).to redirect_to(page_path(:permission))
            end
          end
        end
      end

      # TODO: Consider sharerd scenario for this only
      context "when no user is signed in" do
        it "redirects to the login page" do
          get new_business_type_form_path(:reg_identifier)

          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end

    ### POST FORM - START
    # include_examples "POST form",
    #                  "business_type_form",
    #                  valid_params: { business_type: "limitedCompany" },
    #                  invalid_params: { business_type: "foo" },
    #                  test_attribute: :business_type
    describe "POST business_type_form_path" do
      context "when a valid user is signed in" do
        let(:user) { create(:user) }

        before(:each) do
          sign_in(user)
        end

        context "when no renewal is in progress" do
          let(:registration) do
            create(:registration,
                   :has_required_data,
                   :expires_soon,
                   account_email: user.email)
          end

          let(:params) do
            { reg_identifier: registration.reg_identifier }
          end

          it "redirects to the renewal_start_form and does not create a transient_registration" do
            post_form_with_params(:business_type_form, params)

            expect(response).to redirect_to(new_renewal_start_form_path(registration[:reg_identifier]))

            matching_transient_regs = WasteCarriersEngine::TransientRegistration.where(reg_identifier: registration.reg_identifier)
            expect(matching_transient_regs.any?).to be_falsey
          end

          # TODISCUSS
          context "when the linked registration does not belongs to the logged in user" do
            let(:registration) do
              create(
                :registration,
                :has_required_data,
                :expires_soon
              )
            end

            it "redirects to account permission page" do
              post_form_with_params(:business_type_form, reg_identifier: registration[:reg_identifier])

              expect(response).to redirect_to(page_path(:permission))
            end
          end
        end

        context "when a renewal is in progress" do
          let(:transient_registration) do
            create(
              :transient_registration,
              :has_required_data,
              account_email: user.email,
              workflow_state: workflow_state
            )
          end

          context "when the workflow_state matches the requested form" do
            let(:workflow_state) { :business_type_form }

            context "when the params are valid" do
              let(:params) do
                {
                  business_type_form: { business_type: "limitedCompany" },
                  reg_identifier: transient_registration.reg_identifier
                }
              end

              it "updates the transient registration, changes the workflow state and redirects to the next page" do
                expect(transient_registration.business_type).to eq("limitedCompany")

                post_form_with_params(:business_type_form, params)

                transient_registration.reload

                expect(response).to have_http_status(302)

                expect(transient_registration.business_type).to eq("limitedCompany")
                expect(transient_registration.reload.workflow_state).to_not eq("business_type_form")
              end
            end

            context "when the params are invalid" do
              let(:params) do
                {
                  reg_identifier: transient_registration.reg_identifier,
                  business_type: "Foo"
                }
              end

              it "does not update the transient registration, including workflow_state and shows the form again" do
                post_form_with_params(:business_type_form, params)

                transient_registration.reload

                expect(transient_registration).to eq(transient_registration.reload)
                expect(response).to render_template("business_type_forms/new")
              end
            end

            context "when the params are empty" do
              let(:params) { { reg_identifier: transient_registration.reg_identifier } }

              it "does not throw an error" do
                # rubocop:disable Style/BlockDelimiters
                expect {
                  post_form_with_params(:business_type_form, reg_identifier: transient_registration.reg_identifier)
                }.not_to raise_error
                # rubocop:enable Style/BlockDelimiters
              end
            end

            context "when the reg_identifier is invalid" do
              let(:params) { { reg_identifier: "foo" } }

              it "does not update the transient_registration, including workflow_state and redirect to error page" do
                post_form_with_params(:business_type_form, params)

                expect(transient_registration).to eq(transient_registration.reload)

                expect(response).to redirect_to(page_path("invalid"))
              end
            end

            context "when the registration cannot be renewed" do
              let(:transient_registration) do
                create(
                  :transient_registration,
                  :has_required_data,
                  account_email: user.email,
                  workflow_state: workflow_state,
                  expires_on: Date.today - Rails.configuration.grace_window
                )
              end

              let(:params) do
                {
                  reg_identifier: transient_registration.reg_identifier,
                  business_type: "Foo"
                }
              end

              it "does not update the transient registration, including workflow_state and redirect to error page" do
                post_form_with_params(:business_type_form, params)

                expect(transient_registration).to eq(transient_registration.reload)
                expect(response).to redirect_to(page_path("unrenewable"))
              end
            end
          end

          context "when the workflow_state does not match the requested form" do
            let(:workflow_state) { "payment_summary_form" }
            let(:params) do
              {
                business_type: "limitedCompany",
                reg_identifier: transient_registration.reg_identifier
              }
            end

            it "does not update the transient_registration, including workflow_state and redirects to correct page" do
              post_form_with_params(:business_type_form, params)

              expect(transient_registration).to eq(transient_registration.reload)
              expect(response).to redirect_to(new_payment_summary_form_path(transient_registration.reg_identifier))
            end
          end

          # TODISCUSS
          context "when the transient registration does not belongs to the logged in user" do
            let(:transient_registration) do
              create(
                :transient_registration,
                :has_required_data
              )
            end

            it "redirects to account permission page" do
              post_form_with_params(:business_type_form, reg_identifier: transient_registration[:reg_identifier])

              expect(response).to redirect_to(page_path(:permission))
            end
          end
        end
      end

      # TODO: Consider sharerd scenario for this only
      context "when no user is signed in" do
        it "redirects to the login page" do
          post_form_with_params(:business_type_form, reg_identifier: "123")

          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end
  end
end
