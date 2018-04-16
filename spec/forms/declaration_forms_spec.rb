require "rails_helper"

RSpec.describe DeclarationForm, type: :model do
  describe "#submit" do
    context "when the form is valid" do
      let(:declaration_form) { build(:declaration_form, :has_required_data) }
      let(:valid_params) do
        {
          reg_identifier: declaration_form.reg_identifier,
          declaration: 1
        }
      end

      it "should submit" do
        expect(declaration_form.submit(valid_params)).to eq(true)
      end
    end

    context "when the form is not valid" do
      let(:declaration_form) { build(:declaration_form, :has_required_data) }
      let(:invalid_params) do
        {
          reg_identifier: "foo",
          declaration: "foo"
        }
      end

      it "should not submit" do
        expect(declaration_form.submit(invalid_params)).to eq(false)
      end
    end
  end

  context "when a valid transient registration exists" do
    let(:declaration_form) { build(:declaration_form, :has_required_data) }

    describe "#reg_identifier" do
      context "when a reg_identifier meets the requirements" do
        it "is valid" do
          expect(declaration_form).to be_valid
        end
      end

      context "when a reg_identifier is blank" do
        before(:each) do
          declaration_form.reg_identifier = ""
        end

        it "is not valid" do
          expect(declaration_form).to_not be_valid
        end
      end
    end

    describe "#declaration" do
      context "when a declaration meets the requirements" do
        it "is valid" do
          expect(declaration_form).to be_valid
        end
      end

      context "when a declaration is blank" do
        before(:each) do
          declaration_form.declaration = ""
        end

        it "is not valid" do
          expect(declaration_form).to_not be_valid
        end
      end

      context "when a declaration is 0" do
        before(:each) do
          declaration_form.declaration = 0
        end

        it "is not valid" do
          expect(declaration_form).to_not be_valid
        end
      end
    end
  end

  describe "#transient_registration" do
    context "when the transient registration is invalid" do
      let(:transient_registration) do
        build(:transient_registration,
              workflow_state: "declaration_form")
      end
      # Don't use FactoryBot for this as we need to make sure it initializes with a specific object
      let(:declaration_form) { DeclarationForm.new(transient_registration) }

      before(:each) do
        # Make reg_identifier valid for the form, but not the transient object
        declaration_form.reg_identifier = transient_registration.reg_identifier
        transient_registration.reg_identifier = "foo"
      end

      it "is not valid" do
        expect(declaration_form).to_not be_valid
      end

      it "inherits the errors from the transient_registration" do
        declaration_form.valid?
        expect(declaration_form.errors[:base]).to include(I18n.t("mongoid.errors.models.transient_registration.attributes.reg_identifier.invalid_format"))
      end
    end
  end
end
