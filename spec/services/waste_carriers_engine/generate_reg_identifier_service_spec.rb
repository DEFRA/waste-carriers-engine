# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe GenerateRegIdentifierService do
    describe ".run" do
      context "when the Counter collection is empty" do
        it "creates a regid record and start a counter from 1" do
          expect { described_class.run }.to change { Counter.count }.from(0).to(1)
        end
      end

      context "when the Counter collection is populated" do
        before do
          create(:counter, seq: 3)
        end

        it "returns the currently available sequence integer" do
          expect(described_class.run).to eq(3)
        end

        it "updates the counter with the next available sequence" do
          expect { described_class.run }.to change { Counter.first.seq }.from(3).to(4)
        end

        context "when the Registration collection already has used up an available sequence" do
          before do
            create(:registration, :has_required_data, reg_identifier: "CBDU3")
          end

          it "returns the currently available sequence integer not already used up by a registration" do
            expect(described_class.run).to eq(4)
          end

          it "updates the counter with the next available sequence" do
            expect { described_class.run }.to change { Counter.first.seq }.from(3).to(5)
          end
        end
      end
    end
  end
end
