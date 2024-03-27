# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe CheckYourAnswersFormPresenter do
    subject(:presenter) { described_class.new(transient_registration) }

    describe "#show_smart_answers_results?" do
      context "when the transient_registration is a charity" do
        let(:transient_registration) { instance_double(TransientRegistration, charity?: true) }

        it "returns false" do
          expect(presenter.show_smart_answers_results?).to be false
        end
      end

      context "when the transient_registration is not a charity" do
        before do
          allow(presenter).to receive(:new_registration?).and_return(new_registration)
        end

        context "when the transient_registration is not a new_registration" do
          let(:new_registration) { false }
          let(:transient_registration) { instance_double(TransientRegistration, charity?: false) }

          it "returns true" do
            expect(presenter.show_smart_answers_results?).to be true
          end
        end

        context "when the transient_registration is a new_registration" do
          let(:new_registration) { true }
          let(:transient_registration) do
            instance_double(NewRegistration, charity?: false, tier_known?: tier_known)
          end

          context "when the tier is known to the user" do
            let(:tier_known) { true }

            it "returns false" do
              expect(presenter.show_smart_answers_results?).to be false
            end
          end

          context "when the tier is not known to the user" do
            let(:tier_known) { false }

            it "returns true" do
              expect(presenter.show_smart_answers_results?).to be true
            end
          end
        end
      end
    end

    describe "#entity_display_name" do
      include_context "with a sample registration with defaults", :transient_registration

      describe "#entity_display_name" do
        let(:transient_registration) { resource }
        let(:registered_company_name) { Faker::Company.name }

        it "returns legal_entity_name trading as company_name" do
          expect(presenter.entity_display_name).to eq("#{registered_company_name} trading as #{company_name}")
        end
      end
    end
  end
end
