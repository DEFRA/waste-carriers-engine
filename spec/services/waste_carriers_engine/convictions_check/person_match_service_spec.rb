# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  module ConvictionsCheck
    RSpec.describe PersonMatchService do
      describe "run" do
        let(:time) { Time.new(2019, 1, 1) }
        let(:first_name) { "foo" }
        let(:last_name) { "bar" }
        let(:date_of_birth) { Date.today }
        let(:entity_a) do
          instance_double(Entity,
                          system_flag: "foo",
                          incident_number: "bar",
                          name: "baz")
        end
        let(:entity_b) do
          instance_double(Entity,
                          system_flag: "qux",
                          incident_number: "quux",
                          name: "quuz")
        end

        before do
          allow(Time).to receive(:current).and_return(time)
          allow(Entity).to receive(:matching_people).and_return([entity_a])
        end

        subject(:run_match_service) { described_class.run(first_name: first_name, last_name: last_name, date_of_birth: date_of_birth) }

        it "does not explode" do
          expect { run_match_service }.not_to raise_error
        end

        it "checks for matching entities" do
          run_match_service

          expect(Entity).to have_received(:matching_people).with(first_name: first_name,
                                                                 last_name: last_name,
                                                                 date_of_birth: date_of_birth)
        end

        context "when there are matches" do
          before { allow(Entity).to receive(:matching_people).and_return([entity_a, entity_b]) }

          it "returns a hash of data for the first entity" do
            data = {
              searched_at: time,
              confirmed: "no",
              confirmed_at: nil,
              confirmed_by: nil,
              match_result: "YES",
              matching_system: entity_a.system_flag,
              reference: entity_a.incident_number,
              matched_name: entity_a.name
            }

            expect(run_match_service).to eq(data)
          end
        end

        context "when there are no matches" do
          before { allow(Entity).to receive(:matching_people).and_return([]) }

          it "returns a hash of data" do
            data = {
              searched_at: time,
              confirmed: "no",
              confirmed_at: nil,
              confirmed_by: nil,
              match_result: "NO"
            }

            expect(run_match_service).to eq(data)
          end
        end

        context "when there is an error" do
          before { allow(Entity).to receive(:matching_people).and_raise(ArgumentError) }

          it "returns a hash of data" do
            data = {
              searched_at: time,
              confirmed: "no",
              confirmed_at: nil,
              confirmed_by: nil,
              match_result: "UNKNOWN",
              matching_system: "ERROR"
            }

            expect(run_match_service).to eq(data)
          end
        end
      end
    end
  end
end
