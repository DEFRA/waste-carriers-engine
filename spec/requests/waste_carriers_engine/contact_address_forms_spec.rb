# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "ContactAddressForms", type: :request do
    before do
      stub_address_finder_service(uprn: "340116")
    end

    include_examples "GET flexible form", "contact_address_form"

    describe "POST contact_address_forms_path" do
      context "when a valid user is signed in" do
        let(:user) { create(:user) }

        before(:each) do
          sign_in(user)
        end

        context "when a valid transient registration exists" do
          let(:transient_registration) do
            create(:renewing_registration,
                   :has_required_data,
                   :has_postcode,
                   account_email: user.email,
                   workflow_state: "contact_address_form")
          end

          context "when valid params are submitted" do
            let(:valid_params) do
              {
                token: transient_registration[:token],
                contact_address: {
                  uprn: "340116"
                }
              }
            end

            it "updates the transient registration" do
              post contact_address_forms_path(transient_registration.token), contact_address_form: valid_params

              expect(transient_registration.reload.contact_address.uprn.to_s).to eq("340116")
            end

            it "returns a 302 response" do
              post contact_address_forms_path(transient_registration.token), contact_address_form: valid_params
              expect(response).to have_http_status(302)
            end

            it "redirects to the check_your_answers form" do
              post contact_address_forms_path(transient_registration.token), contact_address_form: valid_params
              expect(response).to redirect_to(new_check_your_answers_form_path(transient_registration[:token]))
            end

            context "when the transient registration already has addresses" do
              let(:transient_registration) do
                create(:renewing_registration,
                       :has_required_data,
                       :has_addresses,
                       account_email: user.email,
                       workflow_state: "contact_address_form")
              end

              it "should have have the same number of addresses before and after submitting" do
                number_of_addresses = transient_registration.addresses.count
                post contact_address_forms_path(transient_registration.token), contact_address_form: valid_params
                expect(transient_registration.reload.addresses.count).to eq(number_of_addresses)
              end

              it "updates the old contact address" do
                transient_registration.contact_address.update_attributes(uprn: "123456")

                post contact_address_forms_path(transient_registration.token), contact_address_form: valid_params

                expect(transient_registration.reload.contact_address.uprn).to eq(340_116)
              end
            end
          end
        end

        context "when the transient registration is in the wrong state" do
          let(:transient_registration) do
            create(:renewing_registration,
                   :has_required_data,
                   :has_postcode,
                   account_email: user.email,
                   workflow_state: "renewal_start_form")
          end

          it "does not update the transient registration" do
            post contact_address_forms_path(transient_registration.token)
            expect(transient_registration.reload.addresses.count).to eq(0)
          end

          it "returns a 302 response" do
            post contact_address_forms_path(transient_registration.token)
            expect(response).to have_http_status(302)
          end

          it "redirects to the correct form for the state" do
            post contact_address_forms_path(transient_registration.token)
            expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:token]))
          end
        end
      end
    end

    describe "GET back_contact_address_forms_path" do
      context "when a valid user is signed in" do
        let(:user) { create(:user) }
        before(:each) do
          sign_in(user)
        end

        context "when a valid transient registration exists" do
          let(:transient_registration) do
            create(:renewing_registration,
                   :has_required_data,
                   :has_postcode,
                   account_email: user.email,
                   workflow_state: "contact_address_form")
          end

          context "when the back action is triggered" do
            it "returns a 302 response" do
              get back_contact_address_forms_path(transient_registration[:token])
              expect(response).to have_http_status(302)
            end

            it "redirects to the contact_postcode form" do
              get back_contact_address_forms_path(transient_registration[:token])
              expect(response).to redirect_to(new_contact_postcode_form_path(transient_registration[:token]))
            end
          end
        end

        context "when the transient registration is in the wrong state" do
          let(:transient_registration) do
            create(:renewing_registration,
                   :has_required_data,
                   :has_postcode,
                   account_email: user.email,
                   workflow_state: "renewal_start_form")
          end

          context "when the back action is triggered" do
            it "returns a 302 response" do
              get back_contact_address_forms_path(transient_registration[:token])
              expect(response).to have_http_status(302)
            end

            it "redirects to the correct form for the state" do
              get back_contact_address_forms_path(transient_registration[:token])
              expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:token]))
            end
          end
        end
      end
    end

    describe "GET skip_to_manual_address_contact_address_forms_path" do
      context "when a valid user is signed in" do
        let(:user) { create(:user) }
        before(:each) do
          sign_in(user)
        end

        context "when a valid transient registration exists" do
          let(:transient_registration) do
            create(:renewing_registration,
                   :has_required_data,
                   :has_postcode,
                   account_email: user.email,
                   workflow_state: "contact_address_form")
          end

          context "when the skip_to_manual_address action is triggered" do
            it "returns a 302 response" do
              get skip_to_manual_address_contact_address_forms_path(transient_registration[:token])
              expect(response).to have_http_status(302)
            end

            it "redirects to the contact_address_manual form" do
              get skip_to_manual_address_contact_address_forms_path(transient_registration[:token])
              expect(response).to redirect_to(new_contact_address_manual_form_path(transient_registration[:token]))
            end
          end
        end

        context "when the transient registration is in the wrong state" do
          let(:transient_registration) do
            create(:renewing_registration,
                   :has_required_data,
                   :has_postcode,
                   account_email: user.email,
                   workflow_state: "renewal_start_form")
          end

          context "when the skip_to_manual_address action is triggered" do
            it "returns a 302 response" do
              get skip_to_manual_address_contact_address_forms_path(transient_registration[:token])
              expect(response).to have_http_status(302)
            end

            it "redirects to the correct form for the state" do
              get skip_to_manual_address_contact_address_forms_path(transient_registration[:token])
              expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:token]))
            end
          end
        end
      end
    end
  end
end
