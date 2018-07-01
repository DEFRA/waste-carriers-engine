require "rails_helper"

module WasteCarriersEngine
  RSpec.describe CbdTypeForm, type: :model do
    describe "#submit" do
      context "when the form is valid" do
        let(:cbd_type_form) { build(:cbd_type_form, :has_required_data) }
        let(:valid_params) { { reg_identifier: cbd_type_form.reg_identifier, registration_type: cbd_type_form.registration_type } }

        it "should submit" do
          expect(cbd_type_form.submit(valid_params)).to eq(true)
        end
      end

      context "when the form is not valid" do
        let(:cbd_type_form) { build(:cbd_type_form, :has_required_data) }
        let(:invalid_params) { { reg_identifier: "foo", registration_type: "bar" } }

        it "should not submit" do
          expect(cbd_type_form.submit(invalid_params)).to eq(false)
        end
      end
    end

    include_examples "validate registration_type", form = :cbd_type_form
  end
end
