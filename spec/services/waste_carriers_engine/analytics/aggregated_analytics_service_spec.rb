# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  module Analytics
    RSpec.describe AggregatedAnalyticsService do

      describe ".run" do
        let(:expected_structure) do
          {
            total_journeys_started: an_instance_of(Integer),
            total_journeys_completed: an_instance_of(Integer),
            completion_rate: an_instance_of(Float),
            front_office_completions: an_instance_of(Integer),
            back_office_completions: an_instance_of(Integer)
          }
        end

        context "with specific date range" do
          let(:start_date) { 7.days.ago }
          let(:end_date) { Time.zone.today }

          before do
            create_list(:user_journey, 5, :started_digital, created_at: 5.days.ago)
            create_list(:user_journey, 3, :completed_digital, created_at: 3.days.ago)
          end

          it "returns a hash with the correct aggregated data" do
            result = described_class.run(start_date: start_date, end_date: end_date)

            expect(result).to match(expected_structure)
            expect(result[:total_journeys_started]).to eq(8)
            expect(result[:total_journeys_completed]).to eq(3)
            expect(result[:completion_rate]).to eq(3.0 / 8 * 100)
          end

          it "calculates completions for digital and assisted digital channels" do
            create_list(:user_journey, 3, :started_digital, created_at: 5.days.ago)
            create(:user_journey, :completed_digital, created_at: 4.days.ago)
            create(:user_journey, :completed_assisted_digital, created_at: 2.days.ago)

            result = described_class.run(start_date: start_date, end_date: end_date)

            expect(result[:front_office_completions]).to eq(4) # Includes the 3 created in the before block
            expect(result[:back_office_completions]).to eq(1)
          end
        end

        context "with default date range" do
          before do
            create(:user_journey, :started_digital, created_at: 1.year.ago)
            create(:user_journey, :completed_digital, created_at: 6.months.ago)
          end

          it "uses the earliest record date as start_date and today as end_date when no dates are provided" do
            result = described_class.run

            expect(result[:total_journeys_started]).to be >= 1
            expect(result[:total_journeys_completed]).to be >= 1
          end
        end

        context "when no data is available for the date range" do
          let(:start_date) { 30.days.ago }
          let(:end_date) { 21.days.ago }

          it "returns zeros for all metrics" do
            result = described_class.run(start_date: start_date, end_date: end_date)

            expect(result).to match(expected_structure)
            expect(result.values).to all(be_zero)
          end
        end
      end
    end
  end
end
