# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe GenerateRegIdentifierService do
    describe ".run" do
      it "returns a new unique identifier from the counter collection" do
        create(:registration, :has_required_data, reg_identifier: "CBDU1")

        expect(described_class.run).to eq(2)
      end
    end
  end
end
