# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "CompanyNameForms" do
    it_behaves_like "GET flexible form", "company_name_form"

    describe "POST company_name_form_path" do
      it_behaves_like "POST renewal form",
                      "company_name_form",
                      valid_params: { company_name: "WasteCo Ltd" },
                      invalid_params: { company_name: "" },
                      test_attribute: :company_name

      context "when the transient_registration is a new registration" do
        let(:transient_registration) do
          create(:new_registration, :has_required_data, tier: "LOWER", workflow_state: "company_name_form")
        end

        it_behaves_like "POST form",
                        "company_name_form",
                        valid_params: { company_name: "WasteCo Ltd" },
                        invalid_params: { company_name: "" }
      end
    end
  end
end
