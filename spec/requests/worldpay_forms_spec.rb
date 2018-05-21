require "rails_helper"

RSpec.describe "WorldpayForms", type: :request do
  include_examples "GET locked-in form", form = "worldpay_form"

  describe "POST worldpay_forms_path" do
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
                 workflow_state: "worldpay_form")
        end

        context "when valid params are submitted" do
          let(:valid_params) {
            {
              reg_identifier: transient_registration[:reg_identifier]
            }
          }

          it "updates the transient registration" do
            # TODO: Add test once data is submitted through the form
          end

          it "returns a 302 response" do
            post worldpay_forms_path, worldpay_form: valid_params
            expect(response).to have_http_status(302)
          end

          it "redirects to the renewal_complete form" do
            post worldpay_forms_path, worldpay_form: valid_params
            expect(response).to redirect_to(new_renewal_complete_form_path(transient_registration[:reg_identifier]))
          end
        end

        context "when invalid params are submitted" do
          let(:invalid_params) {
            {
              reg_identifier: "foo"
            }
          }

          it "returns a 302 response" do
            post worldpay_forms_path, worldpay_form: invalid_params
            expect(response).to have_http_status(302)
          end

          it "does not update the transient registration" do
            post worldpay_forms_path, worldpay_form: invalid_params
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
            reg_identifier: transient_registration[:reg_identifier]
          }
        }

        it "does not update the transient registration" do
          # TODO: Add test once data is submitted through the form
        end

        it "returns a 302 response" do
          post worldpay_forms_path, worldpay_form: valid_params
          expect(response).to have_http_status(302)
        end

        it "redirects to the correct form for the state" do
          post worldpay_forms_path, worldpay_form: valid_params
          expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
        end
      end
    end
  end

  describe "GET back_worldpay_forms_path" do
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
                 workflow_state: "worldpay_form")
        end

        context "when the back action is triggered" do
          it "returns a 302 response" do
            get back_worldpay_forms_path(transient_registration[:reg_identifier])
            expect(response).to have_http_status(302)
          end

          it "redirects to the payment_summary form" do
            get back_worldpay_forms_path(transient_registration[:reg_identifier])
            expect(response).to redirect_to(new_payment_summary_form_path(transient_registration[:reg_identifier]))
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
            get back_worldpay_forms_path(transient_registration[:reg_identifier])
            expect(response).to have_http_status(302)
          end

          it "redirects to the correct form for the state" do
            get back_worldpay_forms_path(transient_registration[:reg_identifier])
            expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
          end
        end
      end
    end
  end
end
