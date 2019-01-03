# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewalStartForm, type: :model do
    describe "#submit" do
      context "when the form is valid" do
        let(:renewal_start_form) { build(:renewal_start_form, :has_required_data) }
        let(:valid_params) { { reg_identifier: renewal_start_form.reg_identifier } }

        it "should submit" do
          expect(renewal_start_form.submit(valid_params)).to eq(true)
        end
      end

      context "when the form is not valid" do
        let(:renewal_start_form) { build(:renewal_start_form, :has_required_data) }
        let(:invalid_params) { { reg_identifier: "foo" } }

        it "should not submit" do
          expect(renewal_start_form.submit(invalid_params)).to eq(false)
        end
      end
    end
  end
end
