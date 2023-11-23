# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "RenewalStartForms" do
    describe "GET new_renewal_start_form_path" do
      let(:registration) { create(:registration, :has_required_data, :expires_soon) }

      it "redirects to the root_path" do
        get new_renewal_start_form_path(registration.reg_identifier)
        expect(response).to redirect_to(root_path)
      end
    end

    describe "POST renewal_start_forms_path" do
      context "when a user is signed in" do
        let(:user) { create(:user) }

        before do
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

          it "redirects to the invalid token error page and does not create a new transient registration" do
            original_tr_count = RenewingRegistration.count

            post renewal_start_forms_path(invalid_renewal)

            expect(response).to redirect_to(page_path("invalid"))

            expect(RenewingRegistration.count).to eq(original_tr_count)
          end
        end

        context "when the signed-in user owns the registration" do
          context "when a matching registration exists" do
            context "when no renewal is in progress" do
              let(:registration) do
                create(:registration,
                       :has_required_data,
                       :expires_soon,
                       company_name: "Correct Name")
              end

              context "when valid params are submitted" do
                let(:valid_registration) { registration.reg_identifier }

                it "creates a new transient registration with correct data, returns a 302 response and redirects to the business type form" do
                  original_count = RenewingRegistration.count

                  post renewal_start_forms_path(valid_registration)

                  expect(RenewingRegistration.count).to eq(original_count + 1)

                  transient_registration = RenewingRegistration.where(reg_identifier: valid_registration).first
                  expect(transient_registration.reg_identifier).to eq(registration.reg_identifier)
                  expect(transient_registration.company_name).to eq(registration.company_name)

                  expect(response).to have_http_status(:found)
                  expect(response).to redirect_to(new_location_form_path(transient_registration.token))
                end
              end
            end
          end

          context "when a renewal is in progress" do
            let(:transient_registration) do
              create(:renewing_registration,
                     :has_required_data,
                     workflow_state: "renewal_start_form")
            end

            let(:valid_renewal) { transient_registration.token }

            it "does not create a new transient registration, returns a 302 response and redirects to the business type form" do
              # Touch the test object so it gets created now and the count is correct
              transient_registration.touch
              original_tr_count = RenewingRegistration.count

              post renewal_start_forms_path(valid_renewal)

              expect(RenewingRegistration.count).to eq(original_tr_count)
              expect(response).to have_http_status(:found)
              expect(response).to redirect_to(new_location_form_path(valid_renewal))
            end

            context "when the state is different" do
              let(:transient_registration) do
                create(:renewing_registration,
                       :has_required_data,
                       workflow_state: "other_businesses_form")
              end

              it "does not create a new transient registration, returns a 302 response and redirects to the correct form" do
                # Touch the test object so it gets created now and the count is correct
                transient_registration.touch
                original_tr_count = RenewingRegistration.count

                post renewal_start_forms_path(valid_renewal)

                expect(RenewingRegistration.count).to eq(original_tr_count)
                expect(response).to have_http_status(:found)
                expect(response).to redirect_to(new_other_businesses_form_path(valid_renewal))
              end
            end
          end
        end
      end
    end
  end
end
