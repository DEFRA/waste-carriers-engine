# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "DeclareConvictionsForms", type: :request do
    include_examples "GET flexible form", "declare_convictions_form"

    describe "POST declare_convictions_form_path" do
      include_examples "POST renewal form",
                       "declare_convictions_form",
                       valid_params: { declared_convictions: "yes" },
                       invalid_params: { declared_convictions: "foo" },
                       test_attribute: :declared_convictions

      context "when the transient_registration is a new registration" do
        let(:transient_registration) do
          create(:new_registration, workflow_state: "declare_convictions_form")
        end

        include_examples "POST form",
                         "declare_convictions_form",
                         valid_params: { declared_convictions: "yes" },
                         invalid_params: { declared_convictions: "foo" }
      end
    end
  end
end
