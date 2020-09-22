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

      context "when a user is provided" do
        let(:service) { described_class.run(registration: registration, current_user: user) }
        let(:user) { double(:user) }

        context "when the feature flag for the extended grace window is on" do
          before do
            expect(FeatureToggle).to receive(:active?).with(:use_extended_grace_window).and_return(true)
          end

          context "when the user has permission to use the extended grace window" do
            before do
              expect(user).to receive(:can?).with(:use_extended_grace_window, registration).and_return(true)
            end

            it "returns the extended grace window date" do
              expect(service).to eq(expected_date_for_extended_grace_window)
            end
          end
    
          context "when the user does not have permission to use the extended grace window" do
            before do
              expect(user).to receive(:can?).with(:use_extended_grace_window, registration).and_return(false)
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

      context "when no user is provided" do
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
