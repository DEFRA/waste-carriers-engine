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

  describe "#reg_identifier" do
    context "when a valid transient registration exists" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               other_businesses: true,
               workflow_state: "other_businesses_form")
      end
      # Don't use FactoryBot for this as we need to make sure it initializes with a specific object
      let(:other_businesses_form) { OtherBusinessesForm.new(transient_registration) }

      context "when a reg_identifier meets the requirements" do
        before(:each) do
          other_businesses_form.reg_identifier = transient_registration.reg_identifier
        end

        it "is valid" do
          expect(other_businesses_form).to be_valid
        end
      end

      context "when a reg_identifier is blank" do
        before(:each) do
          other_businesses_form.reg_identifier = ""
        end

        it "is not valid" do
          expect(other_businesses_form).to_not be_valid
        end
      end
    end
  end

  describe "#other_businesses" do
    context "when a valid transient registration exists" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               workflow_state: "other_businesses_form")
      end
      # Don't use FactoryBot for this as we need to make sure it initializes with a specific object
      let(:other_businesses_form) { OtherBusinessesForm.new(transient_registration) }

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

  describe "#transient_registration" do
    context "when the transient registration is invalid" do
      let(:transient_registration) do
        build(:transient_registration,
              workflow_state: "other_businesses_form")
      end
      # Don't use FactoryBot for this as we need to make sure it initializes with a specific object
      let(:other_businesses_form) { OtherBusinessesForm.new(transient_registration) }

      before(:each) do
        # Make reg_identifier valid for the form, but not the transient object
        other_businesses_form.reg_identifier = transient_registration.reg_identifier
        transient_registration.reg_identifier = "foo"
      end

      it "is not valid" do
        expect(other_businesses_form).to_not be_valid
      end

      it "inherits the errors from the transient_registration" do
        other_businesses_form.valid?
        expect(other_businesses_form.errors[:base]).to include(I18n.t("mongoid.errors.models.transient_registration.attributes.reg_identifier.invalid_format"))
      end
    end
  end
end
