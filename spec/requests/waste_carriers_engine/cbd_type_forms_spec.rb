# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "CbdTypeForms" do
    it_behaves_like "GET flexible form", "cbd_type_form"

    describe "POST cbd_type_form_path" do
      it_behaves_like "POST renewal form",
                      "cbd_type_form",
                      valid_params: { registration_type: "broker_dealer" },
                      invalid_params: { registration_type: "foo" },
                      test_attribute: :registration_type

      context "when the transient_registration is a new registration" do
        let(:transient_registration) do
          create(:new_registration, workflow_state: "cbd_type_form")
        end

        it_behaves_like "POST form",
                        "cbd_type_form",
                        valid_params: { registration_type: "broker_dealer" },
                        invalid_params: { registration_type: "foo" }
      end
    end
  end
end
