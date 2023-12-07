# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe WasteCarriersEngine::DataLayerHelper do
    describe "data_layer" do
      let(:class_double) { "WasteCarriersEngine::NewRegistration" }
      let(:upper_tier) { false }
      let(:lower_tier) { false }
      let(:transient_registration) do
        double(:transient_registration,
               upper_tier?: upper_tier,
               lower_tier?: lower_tier)
      end

      # rubocop:disable RSpec/MessageChain
      before do
        allow(transient_registration).to receive_message_chain(:class, :name).and_return(class_double)
      end
      # rubocop:enable RSpec/MessageChain

      it "returns data in the correct format" do
        expected_string = "'journey': 'new', 'tier': 'unknown'"

        expect(helper.data_layer(transient_registration)).to eq(expected_string)
      end

      describe "journeys" do
        context "when the transient_registration is a NewRegistration" do
          let(:class_double) { "WasteCarriersEngine::NewRegistration" }

          it "returns the correct value" do
            expected_string = "'journey': 'new'"

            expect(helper.data_layer(transient_registration)).to include(expected_string)
          end
        end

        context "when the transient_registration is a DeregisteringRegistration" do
          let(:class_double) { "WasteCarriersEngine::DeregisteringRegistration" }

          it "returns the correct value" do
            expected_string = "'journey': 'deregister'"

            expect(helper.data_layer(transient_registration)).to include(expected_string)
          end
        end

        context "when the transient_registration is a RenewingRegistration" do
          let(:class_double) { "WasteCarriersEngine::RenewingRegistration" }

          it "returns the correct value" do
            expected_string = "'journey': 'renew'"

            expect(helper.data_layer(transient_registration)).to include(expected_string)
          end
        end

        context "when the transient_registration is not a recognised subtype" do
          let(:class_double) { "Foo" }

          it "raises an error" do
            expect { helper.data_layer(transient_registration) }.to raise_error(DataLayerHelper::UnexpectedSubtypeError)
          end
        end
      end

      describe "tiers" do
        context "when the transient_registration is upper tier" do
          let(:upper_tier) { true }

          it "returns the correct value" do
            expected_string = "'tier': 'upper'"

            expect(helper.data_layer(transient_registration)).to include(expected_string)
          end
        end

        context "when the transient_registration is lower tier" do
          let(:lower_tier) { true }

          it "returns the correct value" do
            expected_string = "'tier': 'lower'"

            expect(helper.data_layer(transient_registration)).to include(expected_string)
          end
        end

        context "when the transient_registration is neither upper nor lower tier" do
          it "returns the correct value" do
            expected_string = "'tier': 'unknown'"

            expect(helper.data_layer(transient_registration)).to include(expected_string)
          end
        end
      end
    end
  end
end
