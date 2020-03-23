# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe EditBankTransferForm, type: :model do
    describe "#submit" do
      let(:edit_bank_transfer_form) { build(:edit_bank_transfer_form, :has_required_data) }

      context "when the form is valid" do
        it "should submit" do
          expect(edit_bank_transfer_form.submit({})).to eq(true)
        end
      end

      context "when the form is not valid" do
        before do
          expect(edit_bank_transfer_form).to receive(:valid?).and_return(false)
        end

        it "should not submit" do
          expect(edit_bank_transfer_form.submit({})).to eq(false)
        end
      end
    end
  end
end
