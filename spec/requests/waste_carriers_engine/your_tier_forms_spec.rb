# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "YourTierForm", type: :request do
    let(:new_registration) { create(:new_registration, workflow_state: "your_tier_form") }

    describe "GET new_your_tier_form_path" do
      it "returns a 200 response and render the new template" do
        get new_your_tier_form_path(token: new_registration.token)

        expect(response).to render_template(:new)
        expect(response).to have_http_status(200)
      end
    end

    describe "POST your_tier_form_path" do
      let(:params) { { token: new_registration.token } }

      context "when the new registration is a lower tier registration" do
        let(:new_registration) { create(:new_registration, :lower, workflow_state: "your_tier_form") }

        it "updates the transient registration workflow and redirects to the company_name_form with a 302 status code" do
          post new_your_tier_form_path(params)

          new_registration.reload

          expect(response).to redirect_to(new_company_name_form_path(new_registration.token))
          expect(response).to have_http_status(302)
          expect(new_registration.workflow_state).to eq("company_name_form")
        end
      end

      context "when the new registration is an upper tier registration" do
        let(:new_registration) { create(:new_registration, :upper, workflow_state: "your_tier_form") }

        it "updates the transient registration workflow and redirects to the cbd_type_form with a 302 status code" do
          post new_your_tier_form_path(params)

          new_registration.reload

          expect(response).to redirect_to(new_cbd_type_form_path(new_registration.token))
          expect(response).to have_http_status(302)
          expect(new_registration.workflow_state).to eq("cbd_type_form")
        end
      end
    end
  end
end
