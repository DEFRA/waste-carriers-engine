# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  module Analytics

    RSpec.describe UserJourney do

      # rubocop:disable RSpec/IndexedLet
      let(:count_1) { Faker::Number.between(from: 1, to: 5) }
      let(:count_2) { Faker::Number.between(from: 1, to: 5) }
      let(:count_3) { Faker::Number.between(from: 1, to: 5) }
      # rubocop:enable RSpec/IndexedLet

      describe "journey type scopes" do
        before do
          create_list(:user_journey, count_1, :registration)
          create_list(:user_journey, count_2, :renewal)
        end

        it { expect(described_class.registrations.length).to eq count_1 }
        it { expect(described_class.renewals.length).to eq count_2 }
      end

      describe "start route scopes" do
        before do
          create_list(:user_journey, count_1, :started_digital)
          create_list(:user_journey, count_2, :started_assisted_digital)
        end

        it { expect(described_class.started_digital.length).to eq count_1 }
        it { expect(described_class.started_assisted_digital.length).to eq count_2 }
      end

      describe "completion scopes" do
        before do
          create_list(:user_journey, count_1, :completed_digital)
          create_list(:user_journey, count_2, :completed_assisted_digital)
          create_list(:user_journey, count_3, completed_at: nil)
        end

        it { expect(described_class.completed_digital.length).to eq count_1 }
        it { expect(described_class.completed_assisted_digital.length).to eq count_2 }
        it { expect(described_class.completed.length).to eq count_1 + count_2 }
        it { expect(described_class.incomplete.length).to eq count_3 }
      end

      describe ".date_range" do
        subject(:date_range_query_results) { described_class.date_range(start_date, end_date) }

        let(:start_date) { 10.days.ago.midnight }
        let(:end_date) { Date.today.midnight }
        let(:journey_started_before_range) { Timecop.freeze(start_date - 2.days) { create(:user_journey, completed_at: start_date - 1.day) } }
        let(:journey_started_at_range_start) { Timecop.freeze(start_date) { create(:user_journey, completed_at: start_date + 1.day) } }
        let(:journey_started_before_range_end) { Timecop.freeze(end_date - 1.day) { create(:user_journey, completed_at: end_date) } }
        let(:journey_started_after_range) { Timecop.freeze(end_date + 1.day) { create(:user_journey, completed_at: end_date + 2.days) } }
        let(:journey_completed_after_range) { Timecop.freeze(start_date) { create(:user_journey, completed_at: end_date + 1.day) } }
        let(:journey_started_before_and_ended_within_range) { Timecop.freeze(start_date - 1.day) { create(:user_journey, completed_at: end_date) } }

        before do
          journey_started_before_range
          journey_started_at_range_start
          journey_started_before_range_end
          journey_started_after_range
          journey_completed_after_range
          journey_started_before_and_ended_within_range
        end

        it { expect(date_range_query_results).not_to include(journey_started_before_range) }
        it { expect(date_range_query_results).to include(journey_started_at_range_start) }
        it { expect(date_range_query_results).to include(journey_started_before_range_end) }
        it { expect(date_range_query_results).not_to include(journey_started_after_range) }
        it { expect(date_range_query_results).not_to include(journey_completed_after_range) }
        it { expect(date_range_query_results).not_to include(journey_started_before_and_ended_within_range) }
      end

      describe "#complete_journey" do
        let(:transient_registration) { create(:new_registration, :has_required_data) }
        let(:journey) { Timecop.freeze(1.hour.ago) { create(:user_journey, token: transient_registration.token) } }
        let(:completion_time) { Time.zone.now }

        before { allow(WasteCarriersEngine.configuration).to receive(:host_is_back_office?).and_return(false) }

        it "updates user journey attributes on completion" do
          Timecop.freeze(completion_time) { journey.complete_journey(transient_registration) }

          expect(journey.completed_at).to eq completion_time
          expect(journey.completed_route).to eq "DIGITAL"
          expect(journey.registration_data).to include(
            transient_registration.attributes.slice(
              "businessType",
              "declaredConvictions",
              "registrationType",
              "tier"
            )
          )
        end
      end

      describe ".average_session_duration" do
        let(:transient_registration_a) { create(:new_registration, :has_required_data) }
        let(:transient_registration_b) { create(:new_registration, :has_required_data) }
        let(:transient_registration_c) { create(:renewing_registration, :has_required_data) }

        let(:journey_a) { Timecop.freeze(6.hours.ago) { create(:user_journey, token: transient_registration_a.token) } }
        let(:journey_b) { Timecop.freeze(4.hours.ago) { create(:user_journey, token: transient_registration_b.token) } }
        let(:journey_c) { Timecop.freeze(1.hour.ago) { create(:user_journey, token: transient_registration_c.token) } }

        let(:completion_time) { Time.zone.now }

        let(:journey_a_duration) { journey_a.completed_at.to_time - journey_a.created_at.to_time }
        let(:journey_b_duration) { journey_b.completed_at.to_time - journey_b.created_at.to_time }
        let(:journey_c_duration) { journey_c.updated_at.to_time - journey_c.created_at.to_time }

        before do
          Timecop.freeze(completion_time) do
            journey_a.complete_journey(transient_registration_a)
            journey_b.complete_journey(transient_registration_b)
            # simulate a non-completion update:
            journey_c.touch
          end
        end

        it "returns the average duration across all user journeys" do
          total_duration = journey_a_duration + journey_b_duration + journey_c_duration

          expect(described_class.average_duration(described_class.all)).to eq total_duration / 3
        end

        context "with completed registrations only" do
          it "returns the average duration across completed journeys only" do
            expect(described_class.average_duration(described_class.completed)).to eq (journey_a_duration + journey_b_duration) / 2
          end
        end

        context "with incomplete registrations only" do
          it "returns the average duration across incomplete journeys only" do
            expect(described_class.average_duration(described_class.incomplete)).to eq journey_c_duration
          end
        end
      end

      describe ".minimum_created_at" do
        before do
          @earliest_created_journey = create(:user_journey, created_at: 5.days.ago)
          @latest_created_journey = create(:user_journey, created_at: 1.day.ago)
        end

        it "returns the earliest created user journey" do
          expect(described_class.minimum_created_at).to be_within(1.second).of(@earliest_created_journey.created_at)
        end
      end
    end
  end
end
