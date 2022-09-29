# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe FeatureToggle do
    describe ".active?" do
      context "when a record exist with the given key" do
        let(:key) { "toggle_1" }

        before do
          create(:feature_toggle, key: key, active: active)
        end

        context "when the toggle is active" do
          let(:active) { true }

          it "returns true" do
            expect(described_class.active?(key)).to be true
          end
        end

        context "when the toggle is not active" do
          let(:active) { false }

          it "returns false" do
            expect(described_class.active?(key)).to be false
          end
        end
      end

      context "when a record does not exist with the given key" do
        context "when a feature toggle config exist" do
          context "when it is configured as active" do
            it "returns true" do
              expect(described_class).to be_active("active_test_feature")
            end

            it "accept either strings or syms" do
              expect(described_class).to be_active(:active_test_feature)
            end
          end

          context "when it is configured as not active" do
            it "returns false" do
              expect(described_class).not_to be_active("not_active_test_feature")
            end
          end

          context "when the feature toggle contains a typo in the return value" do
            it "returns false" do
              expect(described_class).not_to be_active("broken_test_feature")
            end
          end

          context "when the feature toggle contains a typo in the structure level" do
            it "returns false" do
              expect(described_class).not_to be_active("broken_test_feature_2")
            end
          end

          context "when the feature toggle is a string containing 'true'" do
            it "returns true" do
              expect(described_class).to be_active("string_true_test_feature")
            end
          end

          context "when the feature toggle is an environment variable" do
            before do
              # Change the environment variable value for this test only
              stub_const("ENV", ENV.to_hash.merge("ENV_VARIABLE_TEST_FEATURE" => "true"))
              # Force reload of the toggle settings after setting the environment variable
              described_class.send("reload_feature_toggles")
            end

            it "returns true" do
              expect(described_class).to be_active("env_variable_test_feature")
            end
          end
        end

        context "when a feature toggle config does not exist" do
          it "returns false" do
            expect(described_class).not_to be_active("i_do_not_exist")
          end
        end
      end
    end
  end
end
