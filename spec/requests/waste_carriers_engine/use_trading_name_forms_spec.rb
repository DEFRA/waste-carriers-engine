# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "UseTradingNameForms" do
    include_examples "GET flexible form", "use_trading_name_form"

    describe "POST use_trading_name_form_path" do
      include_examples "POST renewal form",
                       "use_trading_name_form",
                       valid_params: { temp_use_trading_name: "no" },
                       invalid_params: { temp_use_trading_name: "" },
                       test_attribute: :temp_use_trading_name

      context "when the transient_registration is a new registration" do
        let(:transient_registration) do
          create(:new_registration, :has_required_data, tier: "LOWER", workflow_state: "use_trading_name_form")
        end

        include_examples "POST form",
                         "use_trading_name_form",
                         valid_params: { temp_use_trading_name: "yes" },
                         invalid_params: { temp_use_trading_name: "" }
      end
    end
  end
end
