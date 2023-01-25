# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "IncorrectCompanyForms" do
    include_examples "GET flexible form", "incorrect_company_form"

    describe "POST incorrect_company_form_path" do
      let(:transient_registration) do
        create(:new_registration, workflow_state: "incorrect_company_form")
      end

      it "redirects to registeration_number_form" do
        post_form_with_params(:incorrect_company_form, transient_registration.token)

        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(new_registration_number_form_path(transient_registration.token))
      end
    end
  end
end
