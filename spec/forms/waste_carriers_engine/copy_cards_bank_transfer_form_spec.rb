# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe CopyCardsBankTransferForm, type: :model do
    describe "#submit" do
      let(:copy_cards_bank_transfer_form) { build(:copy_cards_bank_transfer_form, :has_required_data) }

      context "when the form is valid" do
        let(:valid_params) { { reg_identifier: copy_cards_bank_transfer_form.reg_identifier } }

        it "should submit" do
          expect(copy_cards_bank_transfer_form.submit(valid_params)).to eq(true)
        end
      end

      context "when the form is not valid" do
        before do
          expect(copy_cards_bank_transfer_form).to receive(:valid?).and_return(false)
        end

        it "should not submit" do
          expect(copy_cards_bank_transfer_form.submit({})).to eq(false)
        end
      end
    end
  end
end
