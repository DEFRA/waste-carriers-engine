require "rails_helper"

RSpec.describe TierCheckForm, type: :model do
  describe "#submit" do
    context "when the form is valid" do
      let(:tier_check_form) { build(:tier_check_form, :has_required_data) }
      let(:valid_params) do
        {
          reg_identifier: tier_check_form.reg_identifier,
          temp_tier_check: "false"
        }
      end

      it "should submit" do
        expect(tier_check_form.submit(valid_params)).to eq(true)
      end
    end

    context "when the form is not valid" do
      let(:tier_check_form) { build(:tier_check_form, :has_required_data) }
      let(:invalid_params) { { reg_identifier: "foo" } }

      it "should not submit" do
        expect(tier_check_form.submit(invalid_params)).to eq(false)
      end
    end
  end

  context "when a valid transient registration exists" do
    let(:tier_check_form) { build(:tier_check_form, :has_required_data) }

    describe "#reg_identifier" do
      it "is valid" do
        expect(tier_check_form).to be_valid
      end

      context "when a reg_identifier is blank" do
        before(:each) do
          tier_check_form.reg_identifier = ""
        end

        it "is not valid" do
          expect(tier_check_form).to_not be_valid
        end
      end
    end

    describe "#temp_tier_check" do
      context "when a temp_tier_check is true" do
        before(:each) do
          tier_check_form.temp_tier_check = true
        end

        it "is valid" do
          expect(tier_check_form).to be_valid
        end
      end

      context "when a temp_tier_check is false" do
        before(:each) do
          tier_check_form.temp_tier_check = false
        end

        it "is valid" do
          expect(tier_check_form).to be_valid
        end
      end

      context "when a temp_tier_check is not a boolean" do
        before(:each) do
          tier_check_form.temp_tier_check = "foo"
        end

        it "is not valid" do
          expect(tier_check_form).to_not be_valid
        end
      end

      context "when a temp_tier_check is blank" do
        before(:each) do
          tier_check_form.temp_tier_check = ""
        end

        it "is not valid" do
          expect(tier_check_form).to_not be_valid
        end
      end
    end
  end

  describe "#transient_registration" do
    context "when the transient registration is invalid" do
      let(:transient_registration) do
        build(:transient_registration,
              workflow_state: "tier_check_form")
      end
      # Don't use FactoryBot for this as we need to make sure it initializes with a specific object
      let(:tier_check_form) { TierCheckForm.new(transient_registration) }

      before(:each) do
        # Make reg_identifier valid for the form, but not the transient object
        tier_check_form.reg_identifier = transient_registration.reg_identifier
        transient_registration.reg_identifier = "foo"
      end

      it "is not valid" do
        expect(tier_check_form).to_not be_valid
      end

      it "inherits the errors from the transient_registration" do
        tier_check_form.valid?
        expect(tier_check_form.errors[:base]).to include(I18n.t("mongoid.errors.models.transient_registration.attributes.reg_identifier.invalid_format"))
      end
    end
  end
end
