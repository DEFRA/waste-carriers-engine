require "rails_helper"

RSpec.describe "ConstructionDemolitionForms", type: :request do
  describe "GET new_construction_demolition_path" do
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
                 workflow_state: "construction_demolition_form")
        end

        it "returns a success response" do
          get new_construction_demolition_form_path(transient_registration[:reg_identifier])
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
          get new_construction_demolition_form_path(transient_registration[:reg_identifier])
          expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
        end
      end
    end
  end

  describe "POST construction_demolition_forms_path" do
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
                 workflow_state: "construction_demolition_form")
        end

        context "when valid params are submitted" do
          let(:valid_params) {
            {
              reg_identifier: transient_registration[:reg_identifier],
              construction_waste: "true"
            }
          }

          it "updates the transient registration" do
            post construction_demolition_forms_path, construction_demolition_form: valid_params
            expect(transient_registration.reload[:construction_waste]).to eq(true)
          end

          it "returns a 302 response" do
            post construction_demolition_forms_path, construction_demolition_form: valid_params
            expect(response).to have_http_status(302)
          end

          context "when the registration should change to lower tier" do
            before(:each) do
              transient_registration.update_attributes(other_businesses: false)

              valid_params[:construction_waste] = "false"
            end

            it "redirects to the cannot_renew_lower_tier form" do
              post construction_demolition_forms_path, construction_demolition_form: valid_params
              expect(response).to redirect_to(new_cannot_renew_lower_tier_form_path(transient_registration[:reg_identifier]))
            end
          end

          context "when the registration should stay upper tier" do
            before(:each) do
              transient_registration.update_attributes(other_businesses: false)

              valid_params[:construction_waste] = "true"
            end

            it "redirects to the cbd_type form" do
              post construction_demolition_forms_path, construction_demolition_form: valid_params
              expect(response).to redirect_to(new_cbd_type_form_path(transient_registration[:reg_identifier]))
            end
          end
        end

        context "when invalid params are submitted" do
          let(:invalid_params) {
            {
              construction_waste: "foo"
            }
          }

          it "returns a 302 response" do
            post construction_demolition_forms_path, construction_demolition_form: invalid_params
            expect(response).to have_http_status(302)
          end

          it "does not update the transient registration" do
            post construction_demolition_forms_path, construction_demolition_form: invalid_params
            expect(transient_registration.reload[:reg_identifier]).to_not eq(invalid_params[:reg_identifier])
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
            construction_waste: "false"
          }
        }

        it "does not update the transient registration" do
          post construction_demolition_forms_path, construction_demolition_form: valid_params
          expect(transient_registration.reload[:construction_waste]).to_not eq(false)
        end

        it "returns a 302 response" do
          post construction_demolition_forms_path, construction_demolition_form: valid_params
          expect(response).to have_http_status(302)
        end

        it "redirects to the correct form for the state" do
          post construction_demolition_forms_path, construction_demolition_form: valid_params
          expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
        end
      end
    end
  end

  describe "GET back_construction_demolition_forms_path" do
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
                 workflow_state: "construction_demolition_form")
        end

        context "when the back action is triggered" do
          it "returns a 302 response" do
            get back_construction_demolition_forms_path(transient_registration[:reg_identifier])
            expect(response).to have_http_status(302)
          end

          context "when the business does not carry waste for other businesses or households" do
            before(:each) { transient_registration.update_attributes(other_businesses: false) }

            it "redirects to the other_businesses form" do
              get back_construction_demolition_forms_path(transient_registration[:reg_identifier])
              expect(response).to redirect_to(new_other_businesses_form_path(transient_registration[:reg_identifier]))
            end
          end

          context "when the business does carry waste for other businesses or households" do
            before(:each) { transient_registration.update_attributes(other_businesses: true) }

            it "redirects to the service_provided form" do
              get back_construction_demolition_forms_path(transient_registration[:reg_identifier])
              expect(response).to redirect_to(new_service_provided_form_path(transient_registration[:reg_identifier]))
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
            get back_construction_demolition_forms_path(transient_registration[:reg_identifier])
            expect(response).to have_http_status(302)
          end

          it "redirects to the correct form for the state" do
            get back_construction_demolition_forms_path(transient_registration[:reg_identifier])
            expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
          end
        end
      end
    end
  end
end
