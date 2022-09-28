# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe SecureTokenService do

    describe ".run" do
      context "when the return value" do
        it "is a string" do
          expect(described_class.run).to be_a(String)
        end

        it "is 24 characters in length" do
          expect(described_class.run.length).to eq(24)
        end

        it "contains only alphanumeric characters except 0, O, I and l" do
          expect(described_class.run).to match(/^[a-km-zA-HJ-NP-Z1-9]*$/)
        end
      end

      it "generates a different result each time it is called" do
        results = []
        10.times do
          latest = described_class.run

          expect(results).not_to include(latest)

          results.push(latest)
        end
      end
    end
  end
end
