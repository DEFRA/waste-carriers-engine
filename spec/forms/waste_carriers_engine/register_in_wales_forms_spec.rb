require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RegisterInWalesForm, type: :model do
    describe "#submit" do
      context "when the form is valid" do
        let(:register_in_wales_form) { build(:register_in_wales_form, :has_required_data) }
        let(:valid_params) do
          {
            reg_identifier: register_in_wales_form.reg_identifier
          }
        end

        it "should submit" do
          expect(register_in_wales_form.submit(valid_params)).to eq(true)
        end
      end

      context "when the form is not valid" do
        let(:register_in_wales_form) { build(:register_in_wales_form, :has_required_data) }
        let(:invalid_params) { { reg_identifier: "foo" } }

        it "should not submit" do
          expect(register_in_wales_form.submit(invalid_params)).to eq(false)
        end
      end
    end
  end
end
