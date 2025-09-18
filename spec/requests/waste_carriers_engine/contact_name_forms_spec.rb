# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "ContactNameForms" do
    it_behaves_like "GET flexible form", "contact_name_form"

    describe "POST contact_name_form_path" do
      it_behaves_like "POST renewal form",
                      "contact_name_form",
                      valid_params: { first_name: "Foo", last_name: "Bar" },
                      invalid_params: { first_name: "", last_name: "" },
                      test_attribute: :contact_name

      context "when the transient_registration is a new registration" do
        let(:transient_registration) do
          create(:new_registration, workflow_state: "contact_name_form")
        end

        it_behaves_like "POST form",
                        "contact_name_form",
                        valid_params: { first_name: "Foo", last_name: "Bar" },
                        invalid_params: { first_name: "", last_name: "" }
      end
    end
  end
end
