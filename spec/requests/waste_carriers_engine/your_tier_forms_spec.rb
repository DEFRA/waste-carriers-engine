# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "YourTierForm", type: :request do
    let(:new_registration) { create(:new_registration, :lower, workflow_state: "your_tier_form") }

    describe "GET new_your_tier_form_path" do
      it "returns a 200 response and render the new template" do
        get new_your_tier_form_path(token: new_registration.token)

        expect(response).to render_template(:new)
        expect(response).to have_http_status(:ok)
      end
    end

    describe "POST your_tier_form_path" do
      let(:params) { { token: new_registration.token } }

      RSpec.shared_examples "updates workflow state and redirects" do |business_type, next_form|
        let(:new_registration) { create(:new_registration, tier, business_type: business_type, workflow_state: "your_tier_form") }

        it "updates the transient registration workflow" do
          post new_your_tier_form_path(params)

          new_registration.reload

          expect(new_registration.workflow_state).to eq(next_form)
        end

        it "redirects to the company_name_form with a 302 status code" do
          post new_your_tier_form_path(params)

          new_registration.reload

          expect(response).to redirect_to(send("new_#{next_form}_path", new_registration.token))
        end
      end

      context "when the new registration is a lower tier registration" do
        let(:tier) { :lower }

        %i[charity limitedCompany limitedLiabilityPartnership localAuthority partnership soleTrader].each do |business_type|
          it_behaves_like "updates workflow state and redirects", business_type, "company_name_form"
        end
      end

      context "when the new registration is an upper tier registration" do
        let(:tier) { :upper }

        %i[charity limitedCompany limitedLiabilityPartnership localAuthority partnership soleTrader].each do |business_type|
          it_behaves_like "updates workflow state and redirects", business_type, "cbd_type_form"
        end
      end
    end
  end
end
