# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe SmartAnswersCheckerService do
    let(:transient_registration) { build(:transient_registration) }
    let(:service) { SmartAnswersCheckerService.new(transient_registration) }

    describe "#lower_tier?" do
      context "when other_businesses is no" do
        before { transient_registration.other_businesses = "no" }

        context "when construction_waste is no" do
          before { transient_registration.construction_waste = "no" }

          it "returns true" do
            expect(service.lower_tier?).to eq(true)
          end
        end

        context "when construction_waste is yes" do
          before { transient_registration.construction_waste = "yes" }

          it "returns false" do
            expect(service.lower_tier?).to eq(false)
          end
        end
      end

      context "when other_businesses is yes" do
        before { transient_registration.other_businesses = "yes" }

        context "when is_main_service is no" do
          before { transient_registration.is_main_service = "no" }

          context "when construction_waste is no" do
            before { transient_registration.construction_waste = "no" }

            it "returns true" do
              expect(service.lower_tier?).to eq(true)
            end
          end

          context "when construction_waste is yes" do
            before { transient_registration.construction_waste = "yes" }

            it "returns false" do
              expect(service.lower_tier?).to eq(false)
            end
          end
        end

        context "when is_main_service is yes" do
          before { transient_registration.is_main_service = "yes" }

          context "when only_amf is no" do
            before { transient_registration.only_amf = "no" }

            it "returns false" do
              expect(service.lower_tier?).to eq(false)
            end
          end

          context "when only_amf is yes" do
            before { transient_registration.only_amf = "yes" }

            it "returns true" do
              expect(service.lower_tier?).to eq(true)
            end
          end
        end
      end
    end
  end
end
