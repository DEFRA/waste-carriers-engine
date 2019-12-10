# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RegisterInNorthernIrelandForm, type: :model do
    describe "#submit" do
      let(:register_in_northern_ireland_form) { build(:register_in_northern_ireland_form, :has_required_data) }

      context "when the form is valid" do
        let(:valid_params) do
          {
            token: register_in_northern_ireland_form.token
          }
        end

        it "should submit" do
          expect(register_in_northern_ireland_form.submit(valid_params)).to eq(true)
        end
      end

      context "when the form is not valid" do
        before do
          expect(register_in_northern_ireland_form).to receive(:valid?).and_return(false)
        end

        it "should not submit" do
          expect(register_in_northern_ireland_form.submit({})).to eq(false)
        end
      end
    end
  end
end
