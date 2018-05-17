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

  include_examples "validate location", form = :location_form
end
