require "rails_helper"

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

  context "when a valid transient registration exists" do
    let(:cbd_type_form) { build(:cbd_type_form, :has_required_data) }

    describe "#registration_type" do
      context "when a registration_type meets the requirements" do
        it "is valid" do
          expect(cbd_type_form).to be_valid
        end
      end

      context "when a registration_type is blank" do
        before(:each) do
          cbd_type_form.registration_type = ""
        end

        it "is not valid" do
          expect(cbd_type_form).to_not be_valid
        end
      end

      context "when a registration_type is not in the allowed list" do
        before(:each) do
          cbd_type_form.registration_type = "foo"
        end

        it "is not valid" do
          expect(cbd_type_form).to_not be_valid
        end
      end
    end
  end
end
