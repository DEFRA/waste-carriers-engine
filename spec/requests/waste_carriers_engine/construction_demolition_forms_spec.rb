# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "ConstructionDemolitionForms", type: :request do
    include_examples "GET flexible form", "construction_demolition_form"

    describe "POST construction_demolition_form_path" do
      context "When the transient_registration is a new registration" do
        let(:transient_registration) do
          create(:new_registration, workflow_state: "construction_demolition_form")
        end

        include_examples "POST form",
                         "construction_demolition_form",
                         valid_params: { construction_waste: "yes" },
                         invalid_params: { construction_waste: "foo" }
      end
    end
  end
end
