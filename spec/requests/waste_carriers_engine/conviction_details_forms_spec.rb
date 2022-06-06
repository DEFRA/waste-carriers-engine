# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "ConvictionDetailsForms", type: :request do
    include_examples "GET flexible form", "conviction_details_form"

    describe "POST conviction_details_forms_path" do
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
                   workflow_state: "conviction_details_form")
          end

          context "when valid params are submitted" do
            let(:valid_params) do
              {
                first_name: "Foo",
                last_name: "Bar",
                position: "Baz",
                dob_day: "1",
                dob_month: "1",
                dob_year: "2000"
              }
            end

            it "updates the transient registration, returns a 302 response and redirects to the contact_name form" do
              total_people_count = transient_registration.key_people.count

              post conviction_details_forms_path(transient_registration.token), params: { conviction_details_form: valid_params }

              expect(transient_registration.reload.key_people.count).to eq(total_people_count + 1)
              expect(transient_registration.reload.key_people.last.position).to eq(valid_params[:position])

              expect(response).to have_http_status(302)
              expect(response).to redirect_to(new_contact_name_form_path(transient_registration[:token]))
            end

            context "when there is already a relevant conviction person" do
              let(:relevant_conviction_person) { build(:key_person, :has_required_data, :relevant) }

              before(:each) do
                transient_registration.update_attributes(key_people: [relevant_conviction_person])
              end

              it "increases the total number of people and does not replace the existing relevant conviction person" do
                total_people_count = transient_registration.key_people.count

                post conviction_details_forms_path(transient_registration.token), params: { conviction_details_form: valid_params }

                expect(transient_registration.reload.key_people.count).to eq(total_people_count + 1)
                expect(transient_registration.reload.key_people.first.first_name).to eq(relevant_conviction_person.first_name)
              end
            end

            context "when there is already a main person" do
              let(:main_person) { build(:key_person, :has_required_data, :main) }

              before(:each) do
                transient_registration.update_attributes(key_people: [main_person])
              end

              it "increases the total number of people and does not replace the existing main person" do
                total_people_count = transient_registration.key_people.count

                post conviction_details_forms_path(transient_registration.token), params: { conviction_details_form: valid_params }

                expect(transient_registration.reload.key_people.count).to eq(total_people_count + 1)
                expect(transient_registration.reload.key_people.first.first_name).to eq(main_person.first_name)
              end
            end

            context "when the submit params say to add another" do
              it "redirects to the conviction_details form" do
                post conviction_details_forms_path(transient_registration.token), params: { conviction_details_form: valid_params, commit: "Add another person" }

                expect(response).to redirect_to(new_conviction_details_form_path(transient_registration[:token]))
              end
            end
          end

          context "when invalid params are submitted" do
            let(:invalid_params) do
              {
                first_name: "",
                last_name: "",
                dob_day: "31",
                dob_month: "02",
                dob_year: "2000"
              }
            end

            it "does not increase the total number of people" do
              total_people_count = transient_registration.key_people.count

              post conviction_details_forms_path(transient_registration.token), params: { conviction_details_form: invalid_params }

              expect(transient_registration.reload.key_people.count).to eq(total_people_count)
            end

            context "when there is already a main person" do
              let(:existing_main_person) { build(:key_person, :has_required_data, :main) }

              before(:each) do
                transient_registration.update_attributes(key_people: [existing_main_person])
              end

              it "does not replace the existing main person" do
                post conviction_details_forms_path(transient_registration.token), params: { conviction_details_form: invalid_params }

                expect(transient_registration.reload.key_people.first.first_name).to eq(existing_main_person.first_name)
              end
            end
          end

          context "when blank params are submitted" do
            let(:blank_params) do
              {
                first_name: "",
                last_name: "",
                position: "",
                dob_day: "",
                dob_month: "",
                dob_year: ""
              }
            end

            it "does not increase the total number of people" do
              total_people_count = transient_registration.key_people.count

              post conviction_details_forms_path(transient_registration.token), params: { conviction_details_form: blank_params }

              expect(transient_registration.reload.key_people.count).to eq(total_people_count)
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

          let(:valid_params) do
            {
              first_name: "Foo",
              last_name: "Bar",
              position: "Baz",
              dob_day: "1",
              dob_month: "1",
              dob_year: "2000"
            }
          end

          it "does not update the transient registration, returns a 302 response and redirects to the correct form for the state" do
            post conviction_details_forms_path(transient_registration.token), params: { conviction_details_form: valid_params }

            expect(transient_registration.reload.key_people).to_not exist
            expect(response).to have_http_status(302)
            expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:token]))
          end
        end
      end
    end

    describe "DELETE delete_person_conviction_details_forms_path" do
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
                   workflow_state: "conviction_details_form")
          end

          context "when the registration has people with convictions" do
            let(:relevant_person_a) { build(:key_person, :has_required_data, :relevant) }
            let(:relevant_person_b) { build(:key_person, :has_required_data, :relevant) }

            before(:each) do
              transient_registration.update_attributes(key_people: [relevant_person_a, relevant_person_b])
            end

            context "when the delete person action is triggered" do
              it "correctly modifies the list of people, returns a 302 response and redirects to the conviction details form" do
                total_people_count = transient_registration.key_people.count

                delete delete_person_conviction_details_forms_path(id: relevant_person_a[:id], token: transient_registration.token)

                expect(transient_registration.reload.key_people.count).to eq(total_people_count - 1)
                # Removes the correct person
                expect(transient_registration.reload.key_people.where(id: relevant_person_a[:id]).count).to eq(0)
                # Does not affect other people
                expect(transient_registration.reload.key_people.where(id: relevant_person_b[:id]).count).to eq(1)

                expect(response).to have_http_status(302)
                expect(response).to redirect_to(new_conviction_details_form_path(transient_registration[:token]))
              end
            end
          end
        end
      end
    end
  end
end
