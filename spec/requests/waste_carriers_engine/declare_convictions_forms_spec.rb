# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "DeclareConvictionsForms" do
    it_behaves_like "GET flexible form", "declare_convictions_form"

    describe "POST declare_convictions_form_path" do
      it_behaves_like "POST renewal form",
                      "declare_convictions_form",
                      valid_params: { declared_convictions: "yes" },
                      invalid_params: { declared_convictions: "foo" },
                      test_attribute: :declared_convictions

      context "when the transient_registration is a new registration" do
        let(:transient_registration) do
          create(:new_registration, workflow_state: "declare_convictions_form")
        end

        it_behaves_like "POST form",
                        "declare_convictions_form",
                        valid_params: { declared_convictions: "yes" },
                        invalid_params: { declared_convictions: "foo" }
      end
    end
  end
end
