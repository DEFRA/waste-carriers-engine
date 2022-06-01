# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "CheckYourTierForms", type: :request do
    describe "GET new_check_your_tier_form_path" do
      context "when a registration is in progress" do
        let(:transient_registration) do
          create(:new_registration,
                 :has_required_data,
                 workflow_state: "check_your_tier_form")
        end

        context "when the workflow_state matches the request" do
          it "loads the requested page and returns a 200 state" do
            get new_check_your_tier_form_path(transient_registration.token)

            expect(response).to render_template(:new)
            expect(response).to have_http_status(200)
          end
        end

        context "when the workflow_state is a flexible form" do
          before do
            transient_registration.update_attributes(workflow_state: "business_type_form")
          end

          it "updates the workflow_state to match the requested page and loads the requested page" do
            get new_check_your_tier_form_path(transient_registration.token)

            expect(transient_registration.reload[:workflow_state]).to eq("check_your_tier_form")
            expect(response).to render_template("check_your_tier_forms/new")
          end
        end
      end
    end

    describe "POST check_your_tier_path" do
      let(:transient_registration) do
        create(:new_registration, workflow_state: "check_your_tier_form")
      end

      include_examples "POST form",
                       "check_your_tier_form",
                       valid_params: { temp_check_your_tier: "lower" },
                       invalid_params: { temp_check_your_tier: "foo" }
    end
  end
end
