# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe BankTransferForm, type: :model do
    describe "#submit" do
      context "when the form is valid" do
        let(:bank_transfer_form) { build(:bank_transfer_form, :has_required_data) }
        let(:valid_params) { { reg_identifier: bank_transfer_form.reg_identifier } }

        it "should submit" do
          expect(bank_transfer_form.submit(valid_params)).to eq(true)
        end
      end

      context "when the form is not valid" do
        let(:bank_transfer_form) { build(:bank_transfer_form, :has_required_data) }
        let(:invalid_params) { { reg_identifier: "foo" } }

        it "should not submit" do
          expect(bank_transfer_form.submit(invalid_params)).to eq(false)
        end
      end
    end
  end
end
