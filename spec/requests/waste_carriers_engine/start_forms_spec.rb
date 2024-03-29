# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "StartForms" do

    describe "GET new_start_form_path" do
      it "returns a 200 response and renders the new template" do
        get new_start_form_path

        expect(response).to render_template(:new)
        expect(response).to have_http_status(:ok)
      end
    end

    describe "POST start_form_path" do
      let(:new_registration) { create(:new_registration, workflow_state: "start_form") }

      context "when a new registration token is not passed to the request and params are valid" do
        let(:params) { { start_form: { temp_start_option: "new" } } }

        it "creates a new transient registration of type NewRegistration" do
          expect(WasteCarriersEngine::NewRegistration.count).to eq(0)

          post new_start_form_path(params)

          new_registration = WasteCarriersEngine::NewRegistration.last

          expect(new_registration).to be_present
        end
      end

      context "when a new registration token is not passed to the request and params are invalid" do
        it "does not creates a new transient registration of type NewRegistration" do
          expect(WasteCarriersEngine::NewRegistration.count).to eq(0)

          post new_start_form_path({})

          expect(WasteCarriersEngine::NewRegistration.count).to eq(0)
        end
      end

      context "when the start option is `new`" do
        let(:params) { { start_form: { temp_start_option: "new" }, token: new_registration.token } }

        it "updates the transient registration workflow and redirects to the location_form with a 302 status code" do
          post new_start_form_path(params)

          new_registration.reload

          expect(response).to redirect_to(new_location_form_path(new_registration.token))
          expect(response).to have_http_status(:found)
          expect(new_registration.workflow_state).to eq("location_form")
        end
      end

      context "when the start option is `renew`" do
        let(:params) { { start_form: { temp_start_option: "renew" }, token: new_registration.token } }

        it "redirects to the renewal-stop page" do
          post new_start_form_path(params)

          expect(response).to redirect_to new_renewal_stop_form_path(new_registration.token)
        end
      end

      context "when the temp_start_option is empty" do
        it "renders the :new template with a 200 status code" do
          post new_start_form_path

          expect(response).to render_template(:new)
          expect(response).to have_http_status(:ok)
        end
      end
    end
  end
end
