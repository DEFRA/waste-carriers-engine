# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe LastDayOfGraceWindowService do
    describe "run" do
      let(:registration) { double(:registration) }
      let(:expiry_date) { Date.new(2020, 12, 1) }

      let(:expected_date_for_extended_grace_window) do
        (expiry_date + 3.years) - 1.day
      end
      let(:expected_date_for_covid_grace_window) do
        (expiry_date + 180.days) - 1.day
      end
      let(:expected_date_for_standard_grace_window) do
        (expiry_date + 5.days) - 1.day
      end

      let(:service) { described_class.run(registration: registration) }

      before do
        allow(Rails.configuration).to receive(:end_of_covid_extension).and_return(Date.new(2020, 10, 1))
        allow(Rails.configuration).to receive(:expires_after).and_return(3)
        allow(Rails.configuration).to receive(:covid_grace_window).and_return(180)
        allow(Rails.configuration).to receive(:grace_window).and_return(5)

        expect(ExpiryDateService).to receive(:run).with(registration: registration).and_return(expiry_date)
      end

      context "when no ignore_extended_grace_window argument is given" do
        context "when the feature flag for the extended grace window is on" do
          before do
            expect(FeatureToggle).to receive(:active?).with(:use_extended_grace_window).and_return(true)
          end

          context "when the host app is the back office" do
            before do
              expect(WasteCarriersEngine.configuration).to receive(:host_is_back_office?).and_return(true)
            end

            it "returns the extended grace window date" do
              expect(service).to eq(expected_date_for_extended_grace_window)
            end
          end

          context "when the host app is not the back office" do
            before do
              expect(WasteCarriersEngine.configuration).to receive(:host_is_back_office?).and_return(false)
            end

            context "when the registration had a COVID extension" do
              let(:expiry_date) { Date.new(2020, 6, 1) }

              it "returns the COVID grace window date" do
                expect(service).to eq(expected_date_for_covid_grace_window)
              end
            end

            context "when the registration did not have a COVID extension" do
              it "returns the standard grace window date" do
                expect(service).to eq(expected_date_for_standard_grace_window)
              end
            end
          end
        end

        context "when the feature flag for the extended grace window is off" do
          before do
            expect(FeatureToggle).to receive(:active?).with(:use_extended_grace_window).and_return(false)
          end

          context "when the registration had a COVID extension" do
            let(:expiry_date) { Date.new(2020, 6, 1) }

            it "returns the COVID grace window date" do
              expect(service).to eq(expected_date_for_covid_grace_window)
            end
          end

          context "when the registration did not have a COVID extension" do
            it "returns the standard grace window date" do
              expect(service).to eq(expected_date_for_standard_grace_window)
            end
          end
        end
      end

      context "when ignore_extended_grace_window is set to true" do
        let(:service) { described_class.run(registration: registration, ignore_extended_grace_window: true) }

        before do
          expect(FeatureToggle).to_not receive(:active?).with(:use_extended_grace_window)
          expect(WasteCarriersEngine.configuration).to_not receive(:host_is_back_office?)
        end

        context "when the registration had a COVID extension" do
          let(:expiry_date) { Date.new(2020, 6, 1) }

          it "returns the COVID grace window date" do
            expect(service).to eq(expected_date_for_covid_grace_window)
          end
        end

        context "when the registration did not have a COVID extension" do
          it "returns the standard grace window date" do
            expect(service).to eq(expected_date_for_standard_grace_window)
          end
        end
      end
    end
  end
end
