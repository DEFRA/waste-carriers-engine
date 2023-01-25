# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "ServiceProvidedForms" do
    include_examples "GET flexible form", "service_provided_form"

    describe "POST service_provided_form_path" do
      context "when the transient_registration is a new registration" do
        let(:transient_registration) do
          create(:new_registration, workflow_state: "service_provided_form")
        end

        include_examples "POST form",
                         "service_provided_form",
                         valid_params: { is_main_service: "yes" },
                         invalid_params: { is_main_service: "foo" }
      end
    end
  end
end
