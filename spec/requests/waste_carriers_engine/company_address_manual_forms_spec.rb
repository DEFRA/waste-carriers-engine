# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "CompanyAddressManualForms" do
    include_examples "GET flexible form", "company_address_manual_form"

    describe "POST company_address_manual_forms_path" do

      context "when a valid transient registration exists" do
        let(:tier) { WasteCarriersEngine::Registration::UPPER_TIER }
        let(:transient_registration) do
          create(:renewing_registration,
                 :has_required_data,
                 tier: tier,
                 workflow_state: "company_address_manual_form")
        end

        context "when valid params are submitted" do
          let(:valid_params) do
            {
              company_address: {
                house_number: "41",
                address_line_1: "Foo Terrace",
                town_city: "Barton"
              }
            }
          end

          it "updates the transient registration and returns a 302 response" do

            post company_address_manual_forms_path(transient_registration.token), params: { company_address_manual_form: valid_params }

            expect(transient_registration.reload.registered_address.house_number).to eq("41")
            expect(response).to have_http_status(:found)
          end

          context "when the registration is upper tier" do
            let(:tier) { WasteCarriersEngine::Registration::UPPER_TIER }

            it "redirects to the declare_convictions form" do
              post company_address_manual_forms_path(transient_registration.token), params: { company_address_manual_form: valid_params }

              expect(response).to redirect_to(new_declare_convictions_form_path(transient_registration[:token]))
            end
          end

          context "when the registration is lower tier" do
            let(:tier) { WasteCarriersEngine::Registration::LOWER_TIER }

            it "redirects to the contact_name form" do
              post company_address_manual_forms_path(transient_registration.token), params: { company_address_manual_form: valid_params }

              expect(response).to redirect_to(new_contact_name_form_path(transient_registration[:token]))
            end
          end

          context "when the transient registration already has addresses" do
            let(:transient_registration) do
              create(:renewing_registration,
                     :has_required_data,
                     :has_addresses,
                     workflow_state: "company_address_manual_form")
            end

            it "removes the old registered address, adds the new registered address, does not modify the existing contact address, and does not change the total number of addresses" do
              old_registered_address = transient_registration.registered_address
              old_contact_address = transient_registration.contact_address
              number_of_addresses = transient_registration.addresses.count

              post company_address_manual_forms_path(transient_registration.token), params: { company_address_manual_form: valid_params }

              expect(transient_registration.reload.registered_address).not_to eq(old_registered_address)
              expect(transient_registration.reload.registered_address.address_line_1).to eq("Foo Terrace")
              expect(transient_registration.reload.contact_address).to eq(old_contact_address)
              expect(transient_registration.reload.addresses.count).to eq(number_of_addresses)
            end
          end
        end
      end

      context "when the transient registration is in the wrong state" do
        let(:transient_registration) do
          create(:renewing_registration,
                 :has_required_data,
                 workflow_state: "renewal_start_form")
        end

        let(:valid_params) do
          {
            company_address: {
              house_number: "42",
              address_line_1: "Foo Terrace",
              town_city: "Barton"
            }
          }
        end

        it "does not update the transient registration, returns a 302 response and redirects to the correct form for the state" do
          old_registered_address = transient_registration.registered_address

          post company_address_forms_path(transient_registration.token), params: { company_address_form: valid_params }

          expect(transient_registration.reload.registered_address).to eq old_registered_address
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(new_renewal_start_form_path(transient_registration.token))
        end
      end
    end
  end
end
