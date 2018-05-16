require "rails_helper"

RSpec.describe ConstructionDemolitionForm, type: :model do
  describe "#submit" do
    context "when the form is valid" do
      let(:construction_demolition_form) { build(:construction_demolition_form, :has_required_data) }
      let(:valid_params) {
        {
          reg_identifier: construction_demolition_form.reg_identifier,
          construction_waste: construction_demolition_form.construction_waste
        }
      }

      it "should submit" do
        expect(construction_demolition_form.submit(valid_params)).to eq(true)
      end
    end

    context "when the form is not valid" do
      let(:construction_demolition_form) { build(:construction_demolition_form, :has_required_data) }
      let(:invalid_params) { { reg_identifier: "foo" } }

      it "should not submit" do
        expect(construction_demolition_form.submit(invalid_params)).to eq(false)
      end
    end
  end

  context "when a valid transient registration exists" do
    let(:construction_demolition_form) { build(:construction_demolition_form, :has_required_data) }

    describe "#construction_waste" do
      context "when construction_waste is true" do
        before(:each) do
          construction_demolition_form.construction_waste = true
        end

        it "is valid" do
          expect(construction_demolition_form).to be_valid
        end
      end

      context "when construction_waste is false" do
        before(:each) do
          construction_demolition_form.construction_waste = false
        end

        it "is valid" do
          expect(construction_demolition_form).to be_valid
        end
      end

      context "when construction_waste is a non-boolean value" do
        before(:each) do
          construction_demolition_form.construction_waste = "foo"
        end

        it "is not valid" do
          expect(construction_demolition_form).to_not be_valid
        end
      end

      context "when construction_waste is nil" do
        before(:each) do
          construction_demolition_form.construction_waste = nil
        end

        it "is not valid" do
          expect(construction_demolition_form).to_not be_valid
        end
      end
    end
  end
end
