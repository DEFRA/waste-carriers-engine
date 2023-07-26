# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  module Analytics
    RSpec.describe UserJourneyService do

      describe "#run" do
        let(:page) { "start_form" }
        let(:request_path) { "/foo/#{page}" }
        let(:route) { "DIGITAL" }
        let(:transient_registration) { create(:new_registration, :has_required_data) }
        let(:token) { transient_registration.token }
        let(:expected_journey_type) { "registration" }

        before do
          allow(WasteCarriersEngine.configuration).to receive(:host_is_back_office?).and_return false
          allow(UserJourney).to receive(:new).and_call_original
          allow(PageView).to receive(:new).and_call_original
        end

        shared_examples "new journey" do
          it { expect(UserJourney).to have_received(:new) }
          it { expect(PageView).to have_received(:new) }
          it { expect(PageView.last.page).to eq page }
          it { expect(UserJourney.last.token).to eq token }
          it { expect(UserJourney.last.journey_type).to eq expected_journey_type }
        end

        context "when a journey does not already exist for the token" do
          before { described_class.run(transient_registration:) }

          context "with a registration" do
            let(:transient_registration) { create(:new_registration, :has_required_data) }
            let(:expected_journey_type) { "registration" }

            it_behaves_like "new journey"
          end

          context "with a renewal" do
            let(:transient_registration) { create(:renewing_registration, :has_required_data) }
            let(:expected_journey_type) { "renewal" }
            let(:page) { "renewal_start_form" }

            it_behaves_like "new journey"
          end
        end

        context "when a journey already exists for the token" do
          before do
            Timecop.freeze(10.minutes.ago) { create(:user_journey, journey_type: "registration", token: transient_registration.token) }

            described_class.run(transient_registration:)
          end

          it "does not start a new journey" do
            expect(UserJourney).to have_received(:new).once
          end

          it "updates the journey's updated_at timestamp" do
            expect(UserJourney.last.updated_at).to be > UserJourney.last.created_at
          end

          it "creates a page view" do
            expect(PageView).to have_received("new")
          end

          shared_examples "completion form" do |form|
            before do
              transient_registration.workflow_state = form

              described_class.run(transient_registration:)
            end

            it { expect(UserJourney.last.completed_route).not_to be_nil }

            it do
              expect(UserJourney.last.registration_data).to include(
                transient_registration.attributes.slice(:businessType, :registrationType, :declaredConvictions)
              )
            end
          end

          context "when the latest view is a completion form" do
            %w[
              registration_completed_form
              registration_received_pending_conviction_form
              registration_received_pending_govpay_payment_form
              registration_received_pending_payment_form
              renewal_complete_form
              renewal_received_pending_conviction_form
              renewal_received_pending_govpay_payment_form
              renewal_received_pending_payment_form
            ].each do |form|
              it_behaves_like "completion form", form
            end
          end
        end

        context "when it runs in the front office" do
          before do
            allow(WasteCarriersEngine.configuration).to receive(:host_is_back_office?).and_return false

            described_class.run(transient_registration:)
          end

          it { expect(UserJourney.last.started_route).to eq "DIGITAL" }
          it { expect(PageView.last.route).to eq "DIGITAL" }
        end

        context "when it runs in the back office" do
          before do
            allow(WasteCarriersEngine.configuration).to receive(:host_is_back_office?).and_return true

            described_class.run(transient_registration:)
          end

          it { expect(UserJourney.last.started_route).to eq "ASSISTED_DIGITAL" }
          it { expect(PageView.last.route).to eq "ASSISTED_DIGITAL" }
        end

        context "with a logged-in user" do
          let(:current_user) { create(:user) }

          it "stores the current user's email address on the user journey" do
            described_class.run(transient_registration:, current_user:)

            expect(UserJourney.last.user).to eq current_user.email
          end
        end
      end
    end
  end
end
