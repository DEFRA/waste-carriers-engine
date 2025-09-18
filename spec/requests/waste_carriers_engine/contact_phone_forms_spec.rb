# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "ContactPhoneForms" do
    it_behaves_like "GET flexible form", "contact_phone_form"

    describe "POST contact_phone_form_path" do
      it_behaves_like "POST renewal form",
                      "contact_phone_form",
                      valid_params: { phone_number: "01234 567890" },
                      invalid_params: { phone_number: "foo" },
                      test_attribute: :phone_number

      context "when the transient_registration is a new registration" do
        let(:transient_registration) do
          create(:new_registration, workflow_state: "contact_phone_form")
        end

        it_behaves_like "POST form",
                        "contact_phone_form",
                        valid_params: { phone_number: "01234 567890" },
                        invalid_params: { phone_number: "foo" }
      end
    end
  end
end
