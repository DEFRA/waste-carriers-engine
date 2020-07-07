# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "EditCompleteForms", type: :request do
    describe "GET new_edit_complete_form_path" do
      context "when a valid user is signed in" do
        let(:user) { create(:user) }
        before(:each) do
          sign_in(user)
        end

        context "when no edit registration exists" do
          it "redirects to the invalid page" do
            get new_edit_complete_form_path("wibblewobblejellyonaplate")
            expect(response).to redirect_to(page_path("invalid"))
          end
        end

        context "when a valid edit registration exists" do
          let(:different_expires_on) { 3.days.ago }
          let(:updated_email) { "updated@example.com" }
          let(:updated_registered_address) { build(:address, :registered, postcode: "UP1 2DT") }
          let(:updated_contact_address) { build(:address, :contact, postcode: "D1 1FF") }
          let(:updated_person) { build(:key_person, :main, first_name: "Updated") }

          let(:transient_registration) do
            create(:edit_registration,
                   contact_email: updated_email,
                   expires_on: different_expires_on,
                   addresses: [updated_registered_address, updated_contact_address],
                   key_people: [updated_person],
                   workflow_state: "edit_complete_form")
          end
          let(:registration) { transient_registration.registration }

          context "when the workflow_state is correct" do
            it "updates the registration with the new data and deletes the transient object" do
              old_account_email = registration.account_email
              old_expires_on = registration.expires_on
              old_finance_details = registration.finance_details
              old_relevant_people = registration.relevant_people

              get new_edit_complete_form_path(transient_registration.token)
              registration.reload

              # Update base attributes
              expect(registration.contact_email).to eq(updated_email)

              # Update key people
              expect(registration.main_people.count).to eq(1)
              expect(registration.main_people.first.first_name).to eq(updated_person.first_name)

              # Update addresses
              expect(registration.addresses.count).to eq(2)
              expect(registration.registered_address.postcode).to eq(updated_registered_address.postcode)
              expect(registration.contact_address.postcode).to eq(updated_contact_address.postcode)

              # But don't modify finance details or other non-editable attributes
              expect(registration.account_email).to eq(old_account_email)
              expect(registration.expires_on).to eq(old_expires_on)
              expect(registration.expires_on).to_not eq(different_expires_on)
              expect(registration.finance_details).to eq(old_finance_details)
              expect(registration.relevant_people).to eq(old_relevant_people)

              # Delete the transient registration
              expect(WasteCarriersEngine::TransientRegistration.count).to eq(0)

              expect(response).to have_http_status(200)
            end

            context "when there is a change in registration type" do
              let(:transient_registration) do
                create(:edit_registration,
                       :has_changed_registration_type,
                       contact_email: updated_email,
                       addresses: [updated_registered_address, updated_contact_address],
                       key_people: [updated_person],
                       workflow_state: "edit_complete_form")
              end

              it "generates a new order in the registration" do
                old_orders_count = registration.finance_details.orders.count
                transient_registration.prepare_for_payment(:bank_transfer, user)

                get new_edit_complete_form_path(transient_registration.token)

                registration.reload

                expect(registration.finance_details.orders.count).to eq(old_orders_count + 1)
              end
            end
          end

          context "when the workflow_state is not correct" do
            before do
              transient_registration.update_attributes(workflow_state: "declaration_form")
            end

            it "redirects to the correct page, does not update the registration and does not delete the transient object" do
              get new_edit_complete_form_path(transient_registration.token)
              registration.reload

              expect(registration.contact_email).to_not eq(updated_email)

              expect(registration.main_people.first.first_name).to_not eq(updated_person.first_name)

              expect(registration.registered_address.postcode).to_not eq(updated_registered_address.postcode)
              expect(registration.contact_address.postcode).to_not eq(updated_contact_address.postcode)

              expect(WasteCarriersEngine::TransientRegistration.count).to eq(1)

              expect(response).to redirect_to(new_declaration_form_path(transient_registration.token))
            end
          end
        end
      end
    end
  end
end
