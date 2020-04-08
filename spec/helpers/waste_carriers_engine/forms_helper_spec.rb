# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe WasteCarriersEngine::FormsHelper, type: :helper do
    describe "#show_smart_answers_results?" do
      context "when the transient_registration is a charity" do
        let(:transient_registration) { double(:transient_registration, charity?: true) }

        it "returns false" do
          expect(helper.show_smart_answers_results?(transient_registration)).to eq(false)
        end
      end

      context "when the transient_registration is not a charity" do
        context "when the transient_registration is not a new_registration" do
          let(:transient_registration) { double(:transient_registration, charity?: false, new_registration?: false) }

          it "returns true" do
            expect(helper.show_smart_answers_results?(transient_registration)).to eq(true)
          end
        end

        context "when the transient_registration is a new_registration" do
          let(:transient_registration) do
            double(:transient_registration, charity?: false, new_registration?: true, tier_known?: tier_known)
          end

          context "when the tier is known to the user" do
            let(:tier_known) { true }

            it "returns false" do
              expect(helper.show_smart_answers_results?(transient_registration)).to eq(false)
            end
          end

          context "when the tier is not known to the user" do
            let(:tier_known) { false }

            it "returns true" do
              expect(helper.show_smart_answers_results?(transient_registration)).to eq(true)
            end
          end
        end
      end
    end
  end
end
