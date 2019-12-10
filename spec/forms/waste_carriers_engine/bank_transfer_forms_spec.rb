# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe BankTransferForm, type: :model do
    describe "#submit" do
      let(:bank_transfer_form) { build(:bank_transfer_form, :has_required_data) }

      context "when the form is valid" do
        let(:valid_params) { { token: bank_transfer_form.token } }

        it "should submit" do
          expect(bank_transfer_form.submit(valid_params)).to eq(true)
        end
      end

      context "when the form is not valid" do
        before do
          expect(bank_transfer_form).to receive(:valid?).and_return(false)
        end

        it "should not submit" do
          expect(bank_transfer_form.submit({})).to eq(false)
        end
      end
    end
  end
end
