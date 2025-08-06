# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "DeclarationForms" do

    it_behaves_like "GET locked-in form", "declaration_form"

    describe "POST declaration_form_path" do
      it_behaves_like "POST renewal form",
                      "declaration_form",
                      valid_params: { declaration: 1 },
                      invalid_params: { declaration: "foo" },
                      test_attribute: :declaration

      context "when the transient_registration is a new registration" do
        let(:transient_registration) do
          create(:new_registration, workflow_state: "declaration_form")
        end

        it_behaves_like "POST form",
                        "declaration_form",
                        valid_params: { declaration: 1 },
                        invalid_params: { declaration: "foo" }
      end
    end

    describe "POST declaration_forms_path" do

      context "when a valid transient registration exists" do
        let!(:transient_registration) do
          create(:renewing_registration,
                 :has_required_data,
                 :has_key_people,
                 workflow_state: "declaration_form")
        end

        let(:params) { { declaration: 1 } }

        it "creates new conviction_search_results for the registration and key people" do
          post_form_with_params("declaration_form", transient_registration.token, params)

          expect(transient_registration.reload.conviction_search_result).not_to be_nil
          expect(transient_registration.reload.key_people.first.conviction_search_result).not_to be_nil
        end
      end
    end
  end
end
