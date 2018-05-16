require "rails_helper"

RSpec.describe OtherBusinessesForm, type: :model do
  describe "#submit" do
    context "when the form is valid" do
      let(:other_businesses_form) { build(:other_businesses_form, :has_required_data) }
      let(:valid_params) {
        {
          reg_identifier: other_businesses_form.reg_identifier,
          other_businesses: other_businesses_form.other_businesses
        }
      }

      it "should submit" do
        expect(other_businesses_form.submit(valid_params)).to eq(true)
      end
    end

    context "when the form is not valid" do
      let(:other_businesses_form) { build(:other_businesses_form, :has_required_data) }
      let(:invalid_params) { { reg_identifier: "foo" } }

      it "should not submit" do
        expect(other_businesses_form.submit(invalid_params)).to eq(false)
      end
    end
  end

  context "when a valid transient registration exists" do
    describe "#other_businesses" do
      let(:other_businesses_form) { build(:other_businesses_form, :has_required_data) }

      context "when other_businesses is true" do
        before(:each) do
          other_businesses_form.other_businesses = true
        end

        it "is valid" do
          expect(other_businesses_form).to be_valid
        end
      end

      context "when other_businesses is false" do
        before(:each) do
          other_businesses_form.other_businesses = false
        end

        it "is valid" do
          expect(other_businesses_form).to be_valid
        end
      end

      context "when other_businesses is a non-boolean value" do
        before(:each) do
          other_businesses_form.other_businesses = "foo"
        end

        it "is not valid" do
          expect(other_businesses_form).to_not be_valid
        end
      end

      context "when other_businesses is nil" do
        before(:each) do
          other_businesses_form.other_businesses = nil
        end

        it "is not valid" do
          expect(other_businesses_form).to_not be_valid
        end
      end
    end
  end
end
