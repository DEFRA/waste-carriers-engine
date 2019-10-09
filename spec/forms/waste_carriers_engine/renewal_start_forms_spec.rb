# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewalStartForm, type: :model do
    describe "#submit" do
      let(:renewal_start_form) { build(:renewal_start_form, :has_required_data) }
      let(:valid_params) { { reg_identifier: renewal_start_form.reg_identifier } }

      it "should submit" do
        expect(renewal_start_form.submit(valid_params)).to eq(true)
      end
    end
  end
end
