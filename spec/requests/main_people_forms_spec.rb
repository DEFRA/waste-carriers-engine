require "rails_helper"

RSpec.describe "MainPeopleForms", type: :request do
  describe "GET new_main_people_form_path" do
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
                 workflow_state: "main_people_form")
        end

        it "returns a success response" do
          get new_main_people_form_path(transient_registration[:reg_identifier])
          expect(response).to have_http_status(200)
        end
      end

      context "when a transient registration is in a different state" do
        let(:transient_registration) do
          create(:transient_registration,
                 :has_required_data,
                 account_email: user.email,
                 workflow_state: "renewal_start_form")
        end

        it "redirects to the form for the current state" do
          get new_main_people_form_path(transient_registration[:reg_identifier])
          expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
        end
      end
    end
  end

  describe "POST main_people_forms_path" do
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
                 workflow_state: "main_people_form")
        end

        context "when valid params are submitted" do
          let(:valid_params) {
            {
              reg_identifier: transient_registration[:reg_identifier],
              first_name: "Foo",
              last_name: "Bar",
              dob_day: "1",
              dob_month: "1",
              dob_year: "2000"
            }
          }

          it "increases the number of keyPeople" do
            key_people_count = transient_registration.keyPeople.count
            post main_people_forms_path, main_people_form: valid_params
            expect(transient_registration.reload.keyPeople.count).to eq(key_people_count + 1)
          end

          it "updates the transient registration" do
            post main_people_forms_path, main_people_form: valid_params
            expect(transient_registration.reload.keyPeople.last.first_name).to eq(valid_params[:first_name])
          end

          it "returns a 302 response" do
            post main_people_forms_path, main_people_form: valid_params
            expect(response).to have_http_status(302)
          end

          it "redirects to the declare_convictions form" do
            post main_people_forms_path, main_people_form: valid_params
            expect(response).to redirect_to(new_declare_convictions_form_path(transient_registration[:reg_identifier]))
          end

          context "when there is already a main person" do
            let(:existing_main_person) { build(:key_person, :has_required_data, :main) }

            before(:each) do
              transient_registration.update_attributes(keyPeople: [existing_main_person])
            end

            context "when there can be multiple main people" do
              it "does not replace the existing main person" do
                post main_people_forms_path, main_people_form: valid_params
                expect(transient_registration.reload.keyPeople.first.first_name).to eq(existing_main_person.first_name)
              end
            end

            context "when there can only be one main person" do
              before(:each) do
                transient_registration.update_attributes(business_type: "soleTrader")
              end

              it "does not increase the number of keyPeople" do
                key_people_count = transient_registration.keyPeople.count
                post main_people_forms_path, main_people_form: valid_params
                expect(transient_registration.reload.keyPeople.count).to eq(key_people_count)
              end

              it "replaces the existing main person" do
                post main_people_forms_path, main_people_form: valid_params
                expect(transient_registration.reload.keyPeople.first.first_name).to_not eq(existing_main_person.first_name)
              end
            end
          end

          context "when there is a relevant conviction person" do
            let(:relevant_conviction_person) { build(:key_person, :has_required_data, :relevant) }

            before(:each) do
              transient_registration.update_attributes(keyPeople: [relevant_conviction_person])
            end

            context "when there can be multiple key people" do
              it "increases the number of key people" do
                key_people_count = transient_registration.keyPeople.count
                post main_people_forms_path, main_people_form: valid_params
                expect(transient_registration.reload.keyPeople.count).to eq(key_people_count + 1)
              end

              it "does not replace the relevant conviction person" do
                post main_people_forms_path, main_people_form: valid_params
                expect(transient_registration.reload.keyPeople.first.first_name).to eq(relevant_conviction_person.first_name)
              end
            end

            context "when there can only be one main person" do
              before(:each) do
                transient_registration.update_attributes(business_type: "soleTrader")
              end

              it "increases the number of keyPeople" do
                key_people_count = transient_registration.keyPeople.count
                post main_people_forms_path, main_people_form: valid_params
                expect(transient_registration.reload.keyPeople.count).to eq(key_people_count + 1)
              end

              it "adds the new main person" do
                post main_people_forms_path, main_people_form: valid_params
                expect(transient_registration.reload.keyPeople.last.first_name).to eq(valid_params[:first_name])
              end

              it "does not replace the relevant conviction person" do
                post main_people_forms_path, main_people_form: valid_params
                expect(transient_registration.reload.keyPeople.first.first_name).to eq(relevant_conviction_person.first_name)
              end
            end
          end

          context "when the submit params say to add another" do
            it "redirects to the main_people form" do
              post main_people_forms_path, main_people_form: valid_params, commit: I18n.t("main_people_forms.new.add_person_link")
              expect(response).to redirect_to(new_main_people_form_path(transient_registration[:reg_identifier]))
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
            post main_people_forms_path, main_people_form: invalid_params
            expect(response).to have_http_status(302)
          end

          it "does not increase the number of keyPeople" do
            key_people_count = transient_registration.keyPeople.count
            post main_people_forms_path, main_people_form: invalid_params
            expect(transient_registration.reload.keyPeople.count).to eq(key_people_count)
          end

          context "when there is already a main person" do
            let(:existing_main_person) { build(:key_person, :has_required_data, :main) }

            before(:each) do
              transient_registration.update_attributes(keyPeople: [existing_main_person])
            end

            it "does not replace the existing main person" do
              post main_people_forms_path, main_people_form: invalid_params
              expect(transient_registration.reload.keyPeople.first.first_name).to eq(existing_main_person.first_name)
            end
          end

          context "when the submit params say to add another" do
            it "returns a 302 response" do
              post main_people_forms_path, main_people_form: invalid_params, commit: I18n.t("main_people_forms.new.add_person_link")
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
              dob_day: "",
              dob_month: "",
              dob_year: ""
            }
          }

          it "does not increase the number of key people" do
            key_people_count = transient_registration.keyPeople.count
            post main_people_forms_path, main_people_form: blank_params
            expect(transient_registration.reload.keyPeople.count).to eq(key_people_count)
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
            dob_day: "1",
            dob_month: "1",
            dob_year: "2000"
          }
        }

        it "does not update the transient registration" do
          post main_people_forms_path, main_people_form: valid_params
          expect(transient_registration.reload.keyPeople).to_not exist
        end

        it "returns a 302 response" do
          post main_people_forms_path, main_people_form: valid_params
          expect(response).to have_http_status(302)
        end

        it "redirects to the correct form for the state" do
          post main_people_forms_path, main_people_form: valid_params
          expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
        end
      end
    end
  end

  describe "GET back_main_people_forms_path" do
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
                 workflow_state: "main_people_form")
        end

        context "when the back action is triggered" do
          it "returns a 302 response" do
            get back_main_people_forms_path(transient_registration[:reg_identifier])
            expect(response).to have_http_status(302)
          end

          context "when the address was selected from OS places" do
            before(:each) { transient_registration.update_attributes(addresses: [build(:address, :registered, :from_os_places)]) }

            it "redirects to the company_address form" do
              get back_main_people_forms_path(transient_registration[:reg_identifier])
              expect(response).to redirect_to(new_company_address_form_path(transient_registration[:reg_identifier]))
            end
          end

          context "when the address was manually entered" do
            before(:each) { transient_registration.update_attributes(addresses: [build(:address, :registered, :manual_uk)]) }

            it "redirects to the company_address_manual form" do
              get back_main_people_forms_path(transient_registration[:reg_identifier])
              expect(response).to redirect_to(new_company_address_manual_form_path(transient_registration[:reg_identifier]))
            end
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
            get back_main_people_forms_path(transient_registration[:reg_identifier])
            expect(response).to have_http_status(302)
          end

          it "redirects to the correct form for the state" do
            get back_main_people_forms_path(transient_registration[:reg_identifier])
            expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
          end
        end
      end
    end
  end

  describe "DELETE delete_person_main_people_forms_path" do
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
                 workflow_state: "main_people_form")
        end

        context "when the registration has key people" do
          let(:main_person_a) { build(:key_person, :has_required_data, :main) }
          let(:main_person_b) { build(:key_person, :has_required_data, :main) }

          before(:each) do
            transient_registration.update_attributes(keyPeople: [main_person_a, main_person_b])
          end

          context "when the delete person action is triggered" do
            it "returns a 302 response" do
              delete delete_person_main_people_forms_path(main_person_a[:id]), reg_identifier: transient_registration.reg_identifier
              expect(response).to have_http_status(302)
            end

            it "redirects to the main people form" do
              delete delete_person_main_people_forms_path(main_person_a[:id]), reg_identifier: transient_registration.reg_identifier
              expect(response).to redirect_to(new_main_people_form_path(transient_registration[:reg_identifier]))
            end

            it "reduces the number of keyPeople" do
              key_people_count = transient_registration.keyPeople.count
              delete delete_person_main_people_forms_path(main_person_a[:id]), reg_identifier: transient_registration.reg_identifier
              expect(transient_registration.reload.keyPeople.count).to eq(key_people_count - 1)
            end

            it "removes the main person" do
              delete delete_person_main_people_forms_path(main_person_a[:id]), reg_identifier: transient_registration.reg_identifier
              expect(transient_registration.reload.keyPeople.where(id: main_person_a[:id]).count).to eq(0)
            end

            it "does not modify the other keyPeople" do
              delete delete_person_main_people_forms_path(main_person_a[:id]), reg_identifier: transient_registration.reg_identifier
              expect(transient_registration.reload.keyPeople.where(id: main_person_b[:id]).count).to eq(1)
            end
          end
        end
      end
    end
  end
end
