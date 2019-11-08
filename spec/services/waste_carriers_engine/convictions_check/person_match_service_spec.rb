# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  module ConvictionsCheck
    RSpec.describe PersonMatchService do
      describe "run" do
        let(:first_name) { "foo" }
        let(:last_name) { "bar" }
        let(:date_of_birth) { Date.today }

        let(:entity) { double(:entity) }

        let(:subject) do
          described_class.run(first_name: first_name,
                              last_name: last_name,
                              date_of_birth: date_of_birth)
        end

        it "does not explode" do
          expect { subject }.to_not raise_error
        end

        it "checks for matching entities" do
          expect(Entity).to receive(:matching_people).with(first_name: first_name,
                                                           last_name: last_name,
                                                           date_of_birth: date_of_birth)
                                                     .and_return([entity])

          subject
        end

        context "when there are matches" do
          before { allow(Entity).to receive(:matching_people).and_return([entity]) }

          it "returns true" do
            expect(subject).to be(true)
          end
        end

        context "when there are no matches" do
          before { allow(Entity).to receive(:matching_people).and_return([]) }

          it "returns false" do
            expect(subject).to be(false)
          end
        end
      end
    end
  end
end
