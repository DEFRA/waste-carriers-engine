# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "OtherBusinessesForms", type: :request do
    include_examples "GET flexible form", "other_businesses_form"

    describe "POST other_businesses_form_path" do

      context "When the transient_registration is a new registration" do
        let(:transient_registration) do
          create(:new_registration, workflow_state: "other_businesses_form")
        end

        include_examples "POST form",
                         "other_businesses_form",
                         valid_params: { other_businesses: "yes" },
                         invalid_params: { other_businesses: "foo" }
      end
    end
  end
end
