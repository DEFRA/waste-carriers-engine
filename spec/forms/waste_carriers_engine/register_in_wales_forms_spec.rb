# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RegisterInWalesForm, type: :model do
    describe "#submit" do
      let(:register_in_wales_form) { build(:register_in_wales_form, :has_required_data) }

      context "when the form is valid" do
        let(:valid_params) do
          {
            token: register_in_wales_form.token
          }
        end

        it "submits" do
          expect(register_in_wales_form.submit(valid_params)).to be true
        end
      end

      context "when the form is not valid" do
        before do
          allow(register_in_wales_form).to receive(:valid?).and_return(false)
        end

        it "does not submit" do
          expect(register_in_wales_form.submit({})).to be false
        end
      end

    end
  end
end
