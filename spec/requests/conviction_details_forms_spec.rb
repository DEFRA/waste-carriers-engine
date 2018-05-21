require "rails_helper"
require "support/shared_examples/request_get_locked_in_form"

RSpec.describe "ConvictionDetailsForms", type: :request do
  include_examples "GET locked-in form", form = "conviction_details_form"

  describe "POST conviction_details_forms_path" do
    context "when a valid user is signed in" do
      let(:user) { create(:user) }
      before(:each) do
        sign_in(user)
      end

      context "when a valid transient registration exists" do
        let(:transient_registration) do
          create(:transient_registration,
                 :has_required_data,
                 account_email: user.email,
                 workflow_state: "conviction_details_form")
        end

        context "when valid params are submitted" do
          let(:valid_params) {
            {
              reg_identifier: transient_registration[:reg_identifier],
              first_name: "Foo",
              last_name: "Bar",
              position: "Baz",
              dob_day: "1",
              dob_month: "1",
              dob_year: "2000"
            }
          }

          it "increases the total number of people" do
            total_people_count = transient_registration.keyPeople.count
            post conviction_details_forms_path, conviction_details_form: valid_params
            expect(transient_registration.reload.keyPeople.count).to eq(total_people_count + 1)
          end

          it "updates the transient registration" do
            post conviction_details_forms_path, conviction_details_form: valid_params
            expect(transient_registration.reload.keyPeople.last.position).to eq(valid_params[:position])
          end

          it "returns a 302 response" do
            post conviction_details_forms_path, conviction_details_form: valid_params
            expect(response).to have_http_status(302)
          end

          it "redirects to the contact_name form" do
            post conviction_details_forms_path, conviction_details_form: valid_params
            expect(response).to redirect_to(new_contact_name_form_path(transient_registration[:reg_identifier]))
          end

          context "when there is already a relevant conviction person" do
            let(:relevant_conviction_person) { build(:key_person, :has_required_data, :relevant) }

            before(:each) do
              transient_registration.update_attributes(keyPeople: [relevant_conviction_person])
            end

            it "increases the total number of people" do
              total_people_count = transient_registration.keyPeople.count
              post conviction_details_forms_path, conviction_details_form: valid_params
              expect(transient_registration.reload.keyPeople.count).to eq(total_people_count + 1)
            end

            it "does not replace the existing relevant conviction person" do
              post conviction_details_forms_path, conviction_details_form: valid_params
              expect(transient_registration.reload.keyPeople.first.first_name).to eq(relevant_conviction_person.first_name)
            end
          end

          context "when there is already a main person" do
            let(:main_person) { build(:key_person, :has_required_data, :main) }

            before(:each) do
              transient_registration.update_attributes(keyPeople: [main_person])
            end

            it "increases the total number of people" do
              total_people_count = transient_registration.keyPeople.count
              post conviction_details_forms_path, conviction_details_form: valid_params
              expect(transient_registration.reload.keyPeople.count).to eq(total_people_count + 1)
            end

            it "does not replace the existing main person" do
              post conviction_details_forms_path, conviction_details_form: valid_params
              expect(transient_registration.reload.keyPeople.first.first_name).to eq(main_person.first_name)
            end
          end

          context "when the submit params say to add another" do
            it "redirects to the conviction_details form" do
              post conviction_details_forms_path, conviction_details_form: valid_params, commit: I18n.t("conviction_details_forms.new.add_person_link")
              expect(response).to redirect_to(new_conviction_details_form_path(transient_registration[:reg_identifier]))
            end
          end
        end

        context "when invalid params are submitted" do
          let(:invalid_params) {
            {
              reg_identifier: "foo",
              first_name: "",
              last_name: "",
              dob_day: "31",
              dob_month: "02",
              dob_year: "2000"
            }
          }

          it "returns a 302 response" do
            post conviction_details_forms_path, conviction_details_form: invalid_params
            expect(response).to have_http_status(302)
          end

          it "does not increase the total number of people" do
            total_people_count = transient_registration.keyPeople.count
            post conviction_details_forms_path, conviction_details_form: invalid_params
            expect(transient_registration.reload.keyPeople.count).to eq(total_people_count)
          end

          context "when there is already a main person" do
            let(:existing_main_person) { build(:key_person, :has_required_data, :main) }

            before(:each) do
              transient_registration.update_attributes(keyPeople: [existing_main_person])
            end

            it "does not replace the existing main person" do
              post conviction_details_forms_path, conviction_details_form: invalid_params
              expect(transient_registration.reload.keyPeople.first.first_name).to eq(existing_main_person.first_name)
            end
          end

          context "when the submit params say to add another" do
            it "returns a 302 response" do
              post conviction_details_forms_path, conviction_details_form: invalid_params, commit: I18n.t("conviction_details_forms.new.add_person_link")
              expect(response).to have_http_status(302)
            end
          end
        end

        context "when blank params are submitted" do
          let(:blank_params) {
            {
              reg_identifier: "foo",
              first_name: "",
              last_name: "",
              position: "",
              dob_day: "",
              dob_month: "",
              dob_year: ""
            }
          }

          it "does not increase the total number of people" do
            total_people_count = transient_registration.keyPeople.count
            post conviction_details_forms_path, conviction_details_form: blank_params
            expect(transient_registration.reload.keyPeople.count).to eq(total_people_count)
          end
        end
      end

      context "when the transient registration is in the wrong state" do
        let(:transient_registration) do
          create(:transient_registration,
                 :has_required_data,
                 account_email: user.email,
                 workflow_state: "renewal_start_form")
        end

        let(:valid_params) {
          {
            reg_identifier: transient_registration[:reg_identifier],
            first_name: "Foo",
            last_name: "Bar",
            position: "Baz",
            dob_day: "1",
            dob_month: "1",
            dob_year: "2000"
          }
        }

        it "does not update the transient registration" do
          post conviction_details_forms_path, conviction_details_form: valid_params
          expect(transient_registration.reload.keyPeople).to_not exist
        end

        it "returns a 302 response" do
          post conviction_details_forms_path, conviction_details_form: valid_params
          expect(response).to have_http_status(302)
        end

        it "redirects to the correct form for the state" do
          post conviction_details_forms_path, conviction_details_form: valid_params
          expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
        end
      end
    end
  end

  describe "GET back_conviction_details_forms_path" do
    context "when a valid user is signed in" do
      let(:user) { create(:user) }
      before(:each) do
        sign_in(user)
      end

      context "when a valid transient registration exists" do
        let(:transient_registration) do
          create(:transient_registration,
                 :has_required_data,
                 account_email: user.email,
                 workflow_state: "conviction_details_form")
        end

        context "when the back action is triggered" do
          it "returns a 302 response" do
            get back_conviction_details_forms_path(transient_registration[:reg_identifier])
            expect(response).to have_http_status(302)
          end

          it "redirects to the declare_convictions form" do
            get back_conviction_details_forms_path(transient_registration[:reg_identifier])
            expect(response).to redirect_to(new_declare_convictions_form_path(transient_registration[:reg_identifier]))
          end
        end
      end

      context "when the transient registration is in the wrong state" do
        let(:transient_registration) do
          create(:transient_registration,
                 :has_required_data,
                 account_email: user.email,
                 workflow_state: "renewal_start_form")
        end

        context "when the back action is triggered" do
          it "returns a 302 response" do
            get back_conviction_details_forms_path(transient_registration[:reg_identifier])
            expect(response).to have_http_status(302)
          end

          it "redirects to the correct form for the state" do
            get back_conviction_details_forms_path(transient_registration[:reg_identifier])
            expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
          end
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
          create(:transient_registration,
                 :has_required_data,
                 account_email: user.email,
                 workflow_state: "conviction_details_form")
        end

        context "when the registration has people with convictions" do
          let(:relevant_person_a) { build(:key_person, :has_required_data, :relevant) }
          let(:relevant_person_b) { build(:key_person, :has_required_data, :relevant) }

          before(:each) do
            transient_registration.update_attributes(keyPeople: [relevant_person_a, relevant_person_b])
          end

          context "when the delete person action is triggered" do
            it "returns a 302 response" do
              delete delete_person_conviction_details_forms_path(relevant_person_a[:id]), reg_identifier: transient_registration.reg_identifier
              expect(response).to have_http_status(302)
            end

            it "redirects to the conviction details form" do
              delete delete_person_conviction_details_forms_path(relevant_person_a[:id]), reg_identifier: transient_registration.reg_identifier
              expect(response).to redirect_to(new_conviction_details_form_path(transient_registration[:reg_identifier]))
            end

            it "reduces the total number of people" do
              total_people_count = transient_registration.keyPeople.count
              delete delete_person_conviction_details_forms_path(relevant_person_a[:id]), reg_identifier: transient_registration.reg_identifier
              expect(transient_registration.reload.keyPeople.count).to eq(total_people_count - 1)
            end

            it "removes the person" do
              delete delete_person_conviction_details_forms_path(relevant_person_a[:id]), reg_identifier: transient_registration.reg_identifier
              expect(transient_registration.reload.keyPeople.where(id: relevant_person_a[:id]).count).to eq(0)
            end

            it "does not modify the other people" do
              delete delete_person_conviction_details_forms_path(relevant_person_a[:id]), reg_identifier: transient_registration.reg_identifier
              expect(transient_registration.reload.keyPeople.where(id: relevant_person_b[:id]).count).to eq(1)
            end
          end
        end
      end
    end
  end
end
