# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "WasteTypesForms", type: :request do
    include_examples "GET flexible form", "waste_types_form"

    describe "POST waste_types_form_path" do
      context "When the transient_registration is a new registration" do
        let(:transient_registration) do
          create(:new_registration, workflow_state: "waste_types_form")
        end

        include_examples "POST form",
                         "waste_types_form",
                         valid_params: { only_amf: "yes" },
                         invalid_params: { only_amf: "foo" }
      end
    end
  end
end
