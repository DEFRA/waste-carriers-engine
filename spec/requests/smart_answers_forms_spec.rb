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
    end
  end

  # TODO: Add this when following pages are available
  # describe "POST smart_answers_forms_path" do
  #   context "when a user is signed in" do
  #     before(:each) do
  #       user = create(:user)
  #       sign_in(user)
  #     end
  #
  #     context "when a valid transient registration exists" do
  #       let(:transient_registration) do
  #         create(:transient_registration,
  #                :has_required_data,
  #                workflow_state: "smart_answers_form")
  #       end
  #
  #       context "when valid params are submitted" do
  #         let(:valid_params) {
  #           {
  #             reg_identifier: transient_registration[:reg_identifier]
  #           }
  #         }
  #
  #         it "updates the transient registration" do
  #           # TODO: Add test once data is submitted through the form
  #         end
  #
  #         it "returns a 302 response" do
  #           post smart_answers_forms_path, smart_answers_form: valid_params
  #           expect(response).to have_http_status(302)
  #         end
  #
  #         it "redirects to the smart answers form" do
  #           post smart_answers_forms_path, smart_answers_form: valid_params
  #           expect(response).to redirect_to(new_smart_answers_form_path(transient_registration[:reg_identifier]))
  #         end
  #       end
  #
  #       context "when invalid params are submitted" do
  #         let(:invalid_params) {
  #           {
  #             reg_identifier: transient_registration[:reg_identifier]
  #           }
  #         }
  #
  #         it "does not update the transient registration" do
  #           # TODO: Add test once data is submitted through the form
  #         end
  #       end
  #     end
  #   end
  # end

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
    end
  end
end
