require "rails_helper"

RSpec.describe CheckYourAnswersForm, type: :model do
  describe "#submit" do
    context "when the form is valid" do
      let(:check_your_answers_form) { build(:check_your_answers_form, :has_required_data) }
      let(:valid_params) { { reg_identifier: check_your_answers_form.reg_identifier } }

      it "should submit" do
        expect(check_your_answers_form.submit(valid_params)).to eq(true)
      end
    end

    context "when the form is not valid" do
      let(:check_your_answers_form) { build(:check_your_answers_form, :has_required_data) }
      let(:invalid_params) { { reg_identifier: "foo" } }

      it "should not submit" do
        expect(check_your_answers_form.submit(invalid_params)).to eq(false)
      end
    end
  end

  context "when a valid transient registration exists" do
    let(:check_your_answers_form) { build(:check_your_answers_form, :has_required_data) }

    describe "#reg_identifier" do
      context "when a reg_identifier meets the requirements" do
        it "is valid" do
          expect(check_your_answers_form).to be_valid
        end
      end

      context "when a reg_identifier is blank" do
        before(:each) do
          check_your_answers_form.reg_identifier = ""
        end

        it "is not valid" do
          expect(check_your_answers_form).to_not be_valid
        end
      end
    end

    describe "#required_fields_filled_in?" do
      context "when all the fields are present" do
        it "is true" do
          expect(check_your_answers_form.required_fields_filled_in?).to be(true)
        end
      end

      context "when a field is missing" do
        before(:each) do
          check_your_answers_form.company_name = nil
        end

        it "is false" do
          expect(check_your_answers_form.required_fields_filled_in?).to be(false)
        end
      end

      context "when the company_no is missing" do
        before(:each) do
          check_your_answers_form.company_no = nil
        end

        context "when the business_type requires a company_no" do
          before(:each) do
            check_your_answers_form.business_type = "limitedLiabilityPartnership"
          end

          it "is false" do
            expect(check_your_answers_form.required_fields_filled_in?).to be(false)
          end
        end

        context "when the business_type does not require a company_no" do
          before(:each) do
            check_your_answers_form.business_type = "overseas"
          end

          it "is true" do
            expect(check_your_answers_form.required_fields_filled_in?).to be(true)
          end
        end
      end

      context "when there are no relevant_people" do
        before(:each) do
          check_your_answers_form.relevant_people = nil
        end

        context "when declared_convictions expects there to be people" do
          before(:each) do
            check_your_answers_form.declared_convictions = true
          end

          it "is false" do
            expect(check_your_answers_form.required_fields_filled_in?).to be(false)
          end
        end

        context "when declared_convictions does not expect there to be people" do
          before(:each) do
            check_your_answers_form.declared_convictions = false
          end

          it "is true" do
            expect(check_your_answers_form.required_fields_filled_in?).to be(true)
          end
        end
      end
    end
  end

  describe "#transient_registration" do
    context "when the transient registration is invalid" do
      let(:transient_registration) do
        build(:transient_registration,
              workflow_state: "check_your_answers_form")
      end
      # Don't use FactoryBot for this as we need to make sure it initializes with a specific object
      let(:check_your_answers_form) { CheckYourAnswersForm.new(transient_registration) }

      before(:each) do
        # Make reg_identifier valid for the form, but not the transient object
        check_your_answers_form.reg_identifier = transient_registration.reg_identifier
        transient_registration.reg_identifier = "foo"
      end

      it "is not valid" do
        expect(check_your_answers_form).to_not be_valid
      end

      it "inherits the errors from the transient_registration" do
        check_your_answers_form.valid?
        expect(check_your_answers_form.errors[:base]).to include(I18n.t("mongoid.errors.models.transient_registration.attributes.reg_identifier.invalid_format"))
      end
    end
  end
end
