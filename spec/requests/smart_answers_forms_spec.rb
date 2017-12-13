require "rails_helper"

RSpec.describe "SmartAnswersForms", type: :request do
  describe "GET new_smart_answers_path" do
    context "when a user is signed in" do
      before(:each) do
        user = create(:user)
        sign_in(user)
      end

      context "when a valid transient registration exists" do
        let(:transient_registration) do
          create(:transient_registration,
                 :has_required_data,
                 workflow_state: "smart_answers_form")
        end

        it "returns a success response" do
          get new_smart_answers_form_path(transient_registration[:reg_identifier])
          expect(response).to have_http_status(200)
        end
      end

      context "when a transient registration is in a different state" do
        let(:transient_registration) do
          create(:transient_registration,
                 :has_required_data,
                 workflow_state: "renewal_start_form")
        end

        it "redirects to the form for the current state" do
          get new_business_type_form_path(transient_registration[:reg_identifier])
          expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
        end
      end
    end
  end

  # TODO: Add this when following pages are available
  # describe "POST smart_answers_forms_path"

  describe "GET back_smart_answers_forms_path" do
    context "when a user is signed in" do
      before(:each) do
        user = create(:user)
        sign_in(user)
      end

      context "when a valid transient registration exists" do
        let(:transient_registration) do
          create(:transient_registration,
                 :has_required_data,
                 workflow_state: "smart_answers_form")
        end

        context "when the back action is triggered" do
          it "returns a 302 response" do
            get back_smart_answers_forms_path(transient_registration[:reg_identifier])
            expect(response).to have_http_status(302)
          end

          it "redirects to the business type form" do
            get back_smart_answers_forms_path(transient_registration[:reg_identifier])
            expect(response).to redirect_to(new_business_type_form_path(transient_registration[:reg_identifier]))
          end
        end
      end

      context "when the transient registration is in the wrong state" do
        let(:transient_registration) do
          create(:transient_registration,
                 :has_required_data,
                 workflow_state: "renewal_start_form")
        end

        context "when the back action is triggered" do
          it "returns a 302 response" do
            get back_business_type_forms_path(transient_registration[:reg_identifier])
            expect(response).to have_http_status(302)
          end

          it "redirects to the correct form for the state" do
            get back_business_type_forms_path(transient_registration[:reg_identifier])
            expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
          end
        end
      end
    end
  end
end
