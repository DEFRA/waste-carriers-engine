require "rails_helper"

RSpec.describe WasteTypesForm, type: :model do
  describe "#submit" do
    context "when the form is valid" do
      let(:waste_types_form) { build(:waste_types_form, :has_required_data) }
      let(:valid_params) {
        {
          reg_identifier: waste_types_form.reg_identifier,
          only_amf: waste_types_form.only_amf
        }
      }

      it "should submit" do
        expect(waste_types_form.submit(valid_params)).to eq(true)
      end
    end

    context "when the form is not valid" do
      let(:waste_types_form) { build(:waste_types_form, :has_required_data) }
      let(:invalid_params) { { reg_identifier: "foo" } }

      it "should not submit" do
        expect(waste_types_form.submit(invalid_params)).to eq(false)
      end
    end
  end

  context "when a valid transient registration exists" do
    let(:waste_types_form) { build(:waste_types_form, :has_required_data) }

    describe "#only_amf" do
      context "when only_amf is true" do
        before(:each) do
          waste_types_form.only_amf = true
        end

        it "is valid" do
          expect(waste_types_form).to be_valid
        end
      end

      context "when only_amf is false" do
        before(:each) do
          waste_types_form.only_amf = false
        end

        it "is valid" do
          expect(waste_types_form).to be_valid
        end
      end

      context "when only_amf is a non-boolean value" do
        before(:each) do
          waste_types_form.only_amf = "foo"
        end

        it "is not valid" do
          expect(waste_types_form).to_not be_valid
        end
      end

      context "when only_amf is nil" do
        before(:each) do
          waste_types_form.only_amf = nil
        end

        it "is not valid" do
          expect(waste_types_form).to_not be_valid
        end
      end
    end
  end
end
