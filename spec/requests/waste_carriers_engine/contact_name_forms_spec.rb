# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "ContactNameForms", type: :request do
    include_examples "GET flexible form", "contact_name_form"

    describe "POST contact_name_form_path" do
      include_examples "POST renewal form",
                       "contact_name_form",
                       valid_params: { first_name: "Foo", last_name: "Bar" },
                       invalid_params: { first_name: "", last_name: "" },
                       test_attribute: :contact_name

      context "When the transient_registration is a new registration" do
        let(:transient_registration) do
          create(:new_registration, workflow_state: "contact_name_form")
        end

        include_examples "POST form",
                         "contact_name_form",
                         valid_params: { first_name: "Foo", last_name: "Bar" },
                         invalid_params: { first_name: "", last_name: "" }
      end
    end
  end
end
