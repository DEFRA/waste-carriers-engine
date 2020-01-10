# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "CardsForms", type: :request do
    include_examples "GET locked-in form", "cards_form"

    include_examples "POST form",
                     "cards_form",
                     valid_params: { temp_cards: 2 },
                     invalid_params: { temp_cards: 999_999 },
                     test_attribute: :temp_cards

    describe "GET back_cards_forms_path" do
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
                   workflow_state: "cards_form")
          end

          context "when the back action is triggered" do
            it "returns a 302 response" do
              get back_cards_forms_path(transient_registration._id)
              expect(response).to have_http_status(302)
            end

            it "redirects to the declaration form" do
              get back_cards_forms_path(transient_registration._id)
              expect(response).to redirect_to(new_declaration_form_path(transient_registration._id))
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

          context "when the back action is triggered" do
            it "returns a 302 response" do
              get back_cards_forms_path(transient_registration._id)
              expect(response).to have_http_status(302)
            end

            it "redirects to the correct form for the state" do
              get back_cards_forms_path(transient_registration._id)
              expect(response).to redirect_to(new_renewal_start_form_path(transient_registration._id))
            end
          end
        end
      end
    end
  end
end
