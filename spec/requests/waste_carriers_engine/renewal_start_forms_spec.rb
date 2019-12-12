# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "RenewalStartForms", type: :request do
    describe "GET new_renewal_start_form_path" do
      context "when a user is signed in" do
        let(:user) { create(:user) }

        before(:each) do
          sign_in(user)
        end

        context "when no matching registration exists" do
          it "redirects to the invalid token error page" do
            get new_renewal_start_form_path("CBDU999999999")
            expect(response).to redirect_to(page_path("invalid"))
          end
        end

        context "when the token doesn't match the format" do
          it "redirects to the invalid token error page" do
            get new_renewal_start_form_path("foo")
            expect(response).to redirect_to(page_path("invalid"))
          end
        end

        context "when a matching registration exists" do
          context "when the signed-in user owns the registration" do
            context "when no renewal is in progress" do
              let(:registration) { create(:registration, :has_required_data, :expires_soon, account_email: user.email) }

              it "returns a success response" do
                get new_renewal_start_form_path(registration.reg_identifier)
                expect(response).to have_http_status(200)
              end

              context "when the registration cannot be renewed" do
                before(:each) { registration.update_attributes(expires_on: Date.today - Rails.configuration.grace_window) }

                it "redirects to the unrenewable error page" do
                  get new_renewal_start_form_path(registration.reg_identifier)
                  expect(response).to redirect_to(page_path("unrenewable"))
                end
              end
            end

            context "when a renewal is in progress" do
              context "when a valid transient registration exists" do
                let(:transient_registration) do
                  create(:renewing_registration,
                         :has_required_data,
                         account_email: user.email,
                         workflow_state: "renewal_start_form")
                end

                it "returns a success response" do
                  get new_renewal_start_form_path(transient_registration[:token])
                  expect(response).to have_http_status(200)
                end
              end

              context "when the transient registration is in a different state" do
                let(:transient_registration) do
                  create(:renewing_registration,
                         :has_required_data,
                         account_email: user.email,
                         workflow_state: "location_form")
                end

                context "when the token is a reg_identifier" do
                  it "redirects to the form for the current state" do
                    get new_renewal_start_form_path(transient_registration.registration.reg_identifier)

                    expect(response).to redirect_to(new_location_form_path(transient_registration[:token]))
                  end
                end

                it "redirects to the form for the current state" do
                  get new_renewal_start_form_path(transient_registration[:token])

                  expect(response).to redirect_to(new_location_form_path(transient_registration[:token]))
                end
              end
            end
          end

          context "when the signed-in user does not own the registration" do
            context "when no renewal is in progress" do
              let(:registration) do
                create(:registration,
                       :has_required_data,
                       :expires_soon,
                       account_email: "not-#{user.email}")
              end

              it "redirects to the permissions error page" do
                get new_renewal_start_form_path(registration.reg_identifier)
                expect(response).to redirect_to(page_path("permission"))
              end
            end

            context "when a renewal is in progress" do
              let(:transient_registration) do
                create(:renewing_registration,
                       :has_required_data,
                       account_email: "not-#{user.email}",
                       workflow_state: "renewal_start_form")
              end

              it "redirects to the permissions error page" do
                get new_renewal_start_form_path(transient_registration[:token])
                expect(response).to redirect_to(page_path("permission"))
              end
            end
          end
        end
      end

      context "when a user is not signed in" do
        before(:each) do
          user = create(:user)
          sign_out(user)
        end

        it "returns a 302 response" do
          get new_renewal_start_form_path("foo")
          expect(response).to have_http_status(302)
        end

        it "redirects to the sign in page" do
          get new_renewal_start_form_path("foo")
          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end

    describe "POST renewal_start_forms_path" do
      context "when a user is signed in" do
        let(:user) { create(:user) }

        before(:each) do
          sign_in(user)
        end

        context "when no matching registration exists" do
          let(:invalid_registration) { "CBDU99999" }

          it "redirects to the invalid token error page" do
            post renewal_start_forms_path(invalid_registration)

            expect(response).to redirect_to(page_path("invalid"))
          end

          it "does not create a new transient registration" do
            original_tr_count = RenewingRegistration.count
            post renewal_start_forms_path(invalid_registration)
            updated_tr_count = RenewingRegistration.count

            expect(original_tr_count).to eq(updated_tr_count)
          end
        end

        context "when the token doesn't match the format" do
          let(:invalid_renewal) { "foo" }

          it "redirects to the invalid token error page" do
            post renewal_start_forms_path(invalid_renewal)
            expect(response).to redirect_to(page_path("invalid"))
          end

          it "does not create a new transient registration" do
            original_tr_count = RenewingRegistration.count
            post renewal_start_forms_path(invalid_renewal)
            updated_tr_count = RenewingRegistration.count

            expect(original_tr_count).to eq(updated_tr_count)
          end
        end

        context "when the signed-in user owns the registration" do
          context "when a matching registration exists" do
            context "when no renewal is in progress" do
              let(:registration) do
                create(:registration,
                       :has_required_data,
                       :expires_soon,
                       account_email: user.email,
                       company_name: "Correct Name")
              end

              context "when valid params are submitted" do
                let(:valid_registration) { registration.reg_identifier }

                it "creates a new transient registration" do
                  expected_tr_count = RenewingRegistration.count + 1
                  post renewal_start_forms_path(valid_registration)
                  updated_tr_count = RenewingRegistration.count

                  expect(expected_tr_count).to eq(updated_tr_count)
                end

                it "creates a transient registration with correct data" do
                  post renewal_start_forms_path(valid_registration)
                  transient_registration = RenewingRegistration.where(reg_identifier: valid_registration).first

                  expect(transient_registration.reg_identifier).to eq(registration.reg_identifier)
                  expect(transient_registration.company_name).to eq(registration.company_name)
                end

                it "returns a 302 response" do
                  post renewal_start_forms_path(valid_registration)
                  expect(response).to have_http_status(302)
                end

                it "redirects to the business type form" do
                  post renewal_start_forms_path(valid_registration)
                  transient_registration = RenewingRegistration.where(reg_identifier: valid_registration).first

                  expect(response).to redirect_to(new_location_form_path(transient_registration.token))
                end

                context "when the registration cannot be renewed" do
                  before(:each) { registration.update_attributes(expires_on: Date.today - Rails.configuration.grace_window) }

                  it "redirects to the unrenewable error page" do
                    get new_renewal_start_form_path(valid_registration)
                    expect(response).to redirect_to(page_path("unrenewable"))
                  end
                end
              end
            end
          end

          context "when a renewal is in progress" do
            let(:transient_registration) do
              create(:renewing_registration,
                     :has_required_data,
                     account_email: user.email,
                     workflow_state: "renewal_start_form")
            end

            let(:valid_renewal) { transient_registration.token }

            it "returns a 302 response" do
              post renewal_start_forms_path(valid_renewal)
              expect(response).to have_http_status(302)
            end

            it "redirects to the business type form" do
              post renewal_start_forms_path(valid_renewal)
              expect(response).to redirect_to(new_location_form_path(valid_renewal))
            end

            it "does not create a new transient registration" do
              # Touch the test object so it gets created now and the count is correct
              transient_registration.touch

              original_tr_count = RenewingRegistration.count
              post renewal_start_forms_path(valid_renewal)
              updated_tr_count = RenewingRegistration.count

              expect(original_tr_count).to eq(updated_tr_count)
            end

            context "when the state is different" do
              let(:transient_registration) do
                create(:renewing_registration,
                       :has_required_data,
                       account_email: user.email,
                       workflow_state: "other_businesses_form")
              end

              it "returns a 302 response" do
                post renewal_start_forms_path(valid_renewal)
                expect(response).to have_http_status(302)
              end

              it "redirects to the correct form" do
                post renewal_start_forms_path(valid_renewal)
                expect(response).to redirect_to(new_other_businesses_form_path(valid_renewal))
              end

              it "does not create a new transient registration" do
                # Touch the test object so it gets created now and the count is correct
                transient_registration.touch

                original_tr_count = RenewingRegistration.count
                post renewal_start_forms_path(valid_renewal)
                updated_tr_count = RenewingRegistration.count

                expect(original_tr_count).to eq(updated_tr_count)
              end
            end
          end
        end

        context "when the signed-in user does not own the registration" do
          context "when no renewal is in progress" do
            let(:registration) do
              create(:registration,
                     :has_required_data,
                     :expires_soon,
                     account_email: "not-#{user.email}")
            end
            let(:valid_registration) { registration.reg_identifier }

            it "redirects to the permissions error page" do
              post renewal_start_forms_path(valid_registration)
              expect(response).to redirect_to(page_path("permission"))
            end
          end

          context "when a renewal is in progress" do
            let(:transient_registration) do
              create(:renewing_registration,
                     :has_required_data,
                     account_email: "not-#{user.email}",
                     workflow_state: "renewal_start_form")
            end
            let(:valid_renewal) { transient_registration.token }

            it "redirects to the permissions error page" do
              post renewal_start_forms_path(valid_renewal)
              expect(response).to redirect_to(page_path("permission"))
            end
          end
        end
      end

      context "when a user is not signed in" do
        let(:registration) { create(:registration, :has_required_data) }
        let(:valid_registration) { registration.reg_identifier }

        before(:each) do
          user = create(:user)
          sign_out(user)
        end

        it "returns a 302 response" do
          post renewal_start_forms_path(valid_registration)
          expect(response).to have_http_status(302)
        end

        it "redirects to the sign in page" do
          post renewal_start_forms_path(valid_registration)
          expect(response).to redirect_to(new_user_session_path)
        end

        it "does not create a new transient registration" do
          original_tr_count = RenewingRegistration.count
          post renewal_start_forms_path(valid_registration)
          updated_tr_count = RenewingRegistration.count
          expect(original_tr_count).to eq(updated_tr_count)
        end
      end
    end
  end
end
