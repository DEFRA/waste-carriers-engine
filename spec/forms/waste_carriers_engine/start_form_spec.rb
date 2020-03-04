# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe StartForm, type: :model do
    describe "#submit" do
      let(:start_form) { build(:start_form) }

      context "when the form is valid" do
        let(:valid_params) { { temp_start_option: "new" } }

        it "should submit" do
          expect(start_form.submit(valid_params)).to eq(true)
        end
      end

      context "when the form is not valid" do
        it "should not submit" do
          expect(start_form.submit({})).to eq(false)
        end
      end
    end
  end
end
