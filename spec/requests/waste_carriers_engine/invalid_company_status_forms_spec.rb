# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "InvalidCompanyStatusForms" do
    include_examples "GET flexible form", "invalid_company_status_form"

    describe "POST invalid_company_status_form_path" do
      let(:transient_registration) do
        create(:renewing_registration,
               :has_required_data,
               workflow_state: "invalid_company_status_form")
      end
      let(:user) { create(:user) }

      before do
        sign_in(user)
      end

      it "redirects to new registration start form" do
        post_form_with_params(:invalid_company_status_form, transient_registration.token)

        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(new_start_form_path(token: transient_registration.token))
      end
    end
  end
end
