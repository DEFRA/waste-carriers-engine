# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe CheckYourAnswersFormPresenter do
    subject { described_class.new(transient_registration) }

    describe "#show_smart_answers_results?" do
      context "when the transient_registration is a charity" do
        let(:transient_registration) { double(:transient_registration, charity?: true) }

        it "returns false" do
          expect(subject.show_smart_answers_results?).to eq(false)
        end
      end

      context "when the transient_registration is not a charity" do
        before do
          expect(subject).to receive(:new_registration?).and_return(new_registration)
        end

        context "when the transient_registration is not a new_registration" do
          let(:new_registration) { false }
          let(:transient_registration) { double(:transient_registration, charity?: false) }

          it "returns true" do
            expect(subject.show_smart_answers_results?).to eq(true)
          end
        end

        context "when the transient_registration is a new_registration" do
          let(:new_registration) { true }
          let(:transient_registration) do
            double(:transient_registration, charity?: false, tier_known?: tier_known)
          end

          context "when the tier is known to the user" do
            let(:tier_known) { true }

            it "returns false" do
              expect(subject.show_smart_answers_results?).to eq(false)
            end
          end

          context "when the tier is not known to the user" do
            let(:tier_known) { false }

            it "returns true" do
              expect(subject.show_smart_answers_results?).to eq(true)
            end
          end
        end
      end
    end

    describe "#entity_display_name" do
      include_context "Sample registration with defaults", :transient_registration

      describe "#entity_display_name" do
        let(:transient_registration) { resource }
        let(:registered_company_name) { Faker::Company.name }
        it "returns legal_entity_name trading as company_name" do
          expect(subject.entity_display_name).to eq("#{registered_company_name} trading as #{company_name}")
        end
      end
    end
  end
end
