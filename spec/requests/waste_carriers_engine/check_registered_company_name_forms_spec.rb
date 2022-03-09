# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "CheckRegisteredCompanyNameForms", type: :request do
    include_examples "GET flexible form", "check_registered_company_name_form"

    describe "POST check_registered_company_name_form_path" do
      let(:user) { create(:user) }

      before(:each) do
        sign_in(:user)
      end

      context "When the transient_registration is a new registration" do
        let(:transient_registration) do
          create(:new_registration, workflow_state: "check_registered_company_name_form")
        end
      end
    end
  end
end
