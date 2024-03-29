# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe CardsForm do
    describe "#submit" do
      context "when the form is valid" do
        let(:cards_form) { build(:cards_form, :has_required_data) }
        let(:valid_params) do
          {
            token: cards_form.token,
            temp_cards: cards_form.temp_cards
          }
        end

        it "submits" do
          expect(cards_form.submit(valid_params)).to be true
        end
      end

      context "when the form is not valid" do
        let(:cards_form) { build(:cards_form, :has_required_data) }
        let(:invalid_params) do
          {
            temp_cards: described_class::MAX_TEMP_CARDS + 1
          }
        end

        it "does not submit" do
          expect(cards_form.submit(invalid_params)).to be false
        end
      end

      context "when temp_cards is blank" do
        let(:cards_form) { build(:cards_form, :has_required_data) }
        let(:transient_registration) { RenewingRegistration.where(token: cards_form.token).first }
        let(:blank_params) do
          {
            token: cards_form.token,
            temp_cards: ""
          }
        end

        it "changes the value to zero" do
          cards_form.submit(blank_params)
          expect(transient_registration.reload.temp_cards).to eq(0)
        end
      end

      context "when temp_cards is more than 999" do
        let(:cards_form) { build(:cards_form, :has_required_data) }
        let(:transient_registration) { RenewingRegistration.where(token: cards_form.token).first }
        let(:outside_range_params) do
          {
            token: cards_form.token,
            temp_cards: "1000"
          }
        end

        it "does not submit" do
          expect(cards_form.submit(outside_range_params)).to be false
        end
      end
    end

    context "when a valid transient registration exists" do
      let(:cards_form) { build(:cards_form, :has_required_data) }

      describe "#temp_cards" do
        context "when a temp_cards meets the requirements" do
          it "is valid" do
            expect(cards_form).to be_valid
          end
        end

        context "when a temp_cards is blank" do
          before do
            cards_form.transient_registration.temp_cards = nil
          end

          it "is not valid" do
            expect(cards_form).not_to be_valid
          end
        end

        context "when a temp_cards is a negative number" do
          before do
            cards_form.transient_registration.temp_cards = -3
          end

          it "is not valid" do
            expect(cards_form).not_to be_valid
          end
        end
      end
    end
  end
end
