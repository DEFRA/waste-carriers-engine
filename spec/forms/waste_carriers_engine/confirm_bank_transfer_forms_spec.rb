# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe ConfirmBankTransferForm, type: :model do
    describe "#submit" do
      let(:confirm_bank_transfer_form) { build(:confirm_bank_transfer_form, :has_required_data) }

      context "when the form is valid" do
        let(:valid_params) { { token: confirm_bank_transfer_form.token } }

        it "should submit" do
          expect(confirm_bank_transfer_form.submit(valid_params)).to eq(true)
        end
      end

      context "when the form is not valid" do
        before do
          expect(confirm_bank_transfer_form).to receive(:valid?).and_return(false)
        end

        it "should not submit" do
          expect(confirm_bank_transfer_form.submit({})).to eq(false)
        end
      end
    end
  end
end
