# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "ContactAddressManualForms" do
    it_behaves_like "GET flexible form", "contact_address_manual_form"

    describe "POST contact_address_manual_forms_path" do

      context "when a valid transient registration exists" do
        let(:transient_registration) do
          create(:renewing_registration,
                 :has_required_data,
                 workflow_state: "contact_address_manual_form")
        end

        context "when valid params are submitted" do
          let(:valid_params) do
            {
              token: transient_registration[:token],
              contact_address: {
                house_number: "43",
                address_line_1: "Foo Terrace",
                town_city: "Barton"
              }
            }
          end

          it "updates the transient registration, returns a 302 response and redirects to the check_your_answers form" do
            post contact_address_manual_forms_path(transient_registration.token), params: { contact_address_manual_form: valid_params }

            expect(transient_registration.reload.contact_address.house_number).to eq("43")
            expect(response).to have_http_status(:found)
            expect(response).to redirect_to(new_check_your_answers_form_path(transient_registration[:token]))
          end

          context "when the transient registration already has addresses" do
            let(:transient_registration) do
              create(:renewing_registration,
                     :has_required_data,
                     :has_addresses,
                     workflow_state: "contact_address_manual_form")
            end

            it "removes the old contact address, adds the new contact address, does not modify the existing registered address, and does not change the total number of addresses" do
              old_contact_address = transient_registration.contact_address
              old_registered_address = transient_registration.registered_address
              number_of_addresses = transient_registration.addresses.count

              post contact_address_manual_forms_path(transient_registration.token), params: { contact_address_manual_form: valid_params }

              expect(transient_registration.reload.contact_address).not_to eq(old_contact_address)
              expect(transient_registration.reload.contact_address.address_line_1).to eq("Foo Terrace")
              expect(transient_registration.reload.registered_address).to eq(old_registered_address)
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
            token: transient_registration[:token],
            contact_address: {
              house_number: "42",
              address_line_1: "Foo Terrace",
              town_city: "Barton"
            }
          }
        end

        it "does not update the transient registration, returns a 302 response and redirects to the correct form for the state" do
          old_contact_address = transient_registration.contact_address

          post contact_address_forms_path(transient_registration.token), params: { contact_address_form: valid_params }

          expect(transient_registration.reload.contact_address).to eq(old_contact_address)
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:token]))
        end
      end
    end
  end
end
