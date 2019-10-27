# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe SmartAnswersCheckerService do
    let(:other_businesses) {}
    let(:construction_waste) {}
    let(:is_main_service) {}
    let(:only_amf) {}
    let(:transient_registration) do
      double(
        :transient_registration,
        other_businesses: other_businesses,
        construction_waste: construction_waste,
        is_main_service: is_main_service,
        only_amf: only_amf
      )
    end

    let(:service) { described_class.new(transient_registration) }

    describe "#lower_tier?" do
      context "when other_businesses is no" do
        let(:other_businesses) { "no" }

        context "when construction_waste is no" do
          let(:construction_waste) { "no" }

          it "returns true" do
            expect(service.lower_tier?).to eq(true)
          end
        end

        context "when construction_waste is yes" do
          let(:construction_waste) { "yes" }

          it "returns false" do
            expect(service.lower_tier?).to eq(false)
          end
        end
      end

      context "when other_businesses is yes" do
        let(:other_businesses) { "yes" }

        context "when is_main_service is no" do
          let(:is_main_service) { "no" }

          context "when construction_waste is no" do
            let(:construction_waste) { "no" }

            it "returns true" do
              expect(service.lower_tier?).to eq(true)
            end
          end

          context "when construction_waste is yes" do
            let(:construction_waste) { "yes" }

            it "returns false" do
              expect(service.lower_tier?).to eq(false)
            end
          end
        end

        context "when is_main_service is yes" do
          let(:is_main_service) { "yes" }

          context "when only_amf is no" do
            let(:only_amf) { "no" }

            it "returns false" do
              expect(service.lower_tier?).to eq(false)
            end
          end

          context "when only_amf is yes" do
            let(:only_amf) { "yes" }

            it "returns true" do
              expect(service.lower_tier?).to eq(true)
            end
          end
        end
      end
    end
  end
end
