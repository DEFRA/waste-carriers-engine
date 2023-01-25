# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "CardsForms" do
    include_examples "GET locked-in form", "cards_form"

    describe "POST cards_form_path" do
      include_examples "POST renewal form",
                       "cards_form",
                       valid_params: { temp_cards: 2 },
                       invalid_params: { temp_cards: 999_999 },
                       test_attribute: :temp_cards

      context "when the transient_registration is a new registration" do
        let(:transient_registration) do
          create(:new_registration, workflow_state: "cards_form")
        end

        include_examples "POST form",
                         "cards_form",
                         valid_params: { temp_cards: 2 },
                         invalid_params: { temp_cards: 999_999 }
      end
    end
  end
end
