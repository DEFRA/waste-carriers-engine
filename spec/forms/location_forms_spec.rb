require "rails_helper"

RSpec.describe LocationForm, type: :model do
  describe "#submit" do
    context "when the form is valid" do
      let(:location_form) { build(:location_form, :has_required_data) }
      let(:valid_params) do
        {
          reg_identifier: location_form.reg_identifier,
          location: location_form.location
        }
      end

      it "should submit" do
        expect(location_form.submit(valid_params)).to eq(true)
      end
    end

    context "when the form is not valid" do
      let(:location_form) { build(:location_form, :has_required_data) }
      let(:invalid_params) { { reg_identifier: "foo" } }

      it "should not submit" do
        expect(location_form.submit(invalid_params)).to eq(false)
      end
    end
  end

  context "when a valid transient registration exists" do
    let(:location_form) { build(:location_form, :has_required_data) }

    describe "#location" do
      context "when a location meets the requirements" do
        it "is valid" do
          expect(location_form).to be_valid
        end
      end

      context "when a location is blank" do
        before(:each) do
          location_form.location = ""
        end

        it "is not valid" do
          expect(location_form).to_not be_valid
        end
      end

      context "when a location is not in the allowed list" do
        before(:each) do
          location_form.location = "foo"
        end

        it "is not valid" do
          expect(location_form).to_not be_valid
        end
      end
    end
  end
end
