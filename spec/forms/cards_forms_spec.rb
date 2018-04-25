require "rails_helper"

RSpec.describe CardsForm, type: :model do
  describe "#submit" do
    context "when the form is valid" do
      let(:cards_form) { build(:cards_form, :has_required_data) }
      let(:valid_params) do
        {
          reg_identifier: cards_form.reg_identifier,
          temp_cards: cards_form.temp_cards
        }
      end

      it "should submit" do
        expect(cards_form.submit(valid_params)).to eq(true)
      end
    end

    context "when the form is not valid" do
      let(:cards_form) { build(:cards_form, :has_required_data) }
      let(:invalid_params) { { reg_identifier: "foo" } }

      it "should not submit" do
        expect(cards_form.submit(invalid_params)).to eq(false)
      end
    end
  end

  context "when a valid transient registration exists" do
    let(:cards_form) { build(:cards_form, :has_required_data) }

    describe "#reg_identifier" do
      context "when a reg_identifier meets the requirements" do
        it "is valid" do
          expect(cards_form).to be_valid
        end
      end

      context "when a reg_identifier is blank" do
        before(:each) do
          cards_form.reg_identifier = ""
        end

        it "is not valid" do
          expect(cards_form).to_not be_valid
        end
      end
    end

    describe "#temp_cards" do
      context "when a temp_cards meets the requirements" do
        it "is valid" do
          expect(cards_form).to be_valid
        end
      end

      context "when a temp_cards is blank" do
        before(:each) do
          cards_form.temp_cards = ""
        end

        it "is valid" do
          expect(cards_form).to be_valid
        end
      end

      context "when a temp_cards is not a number" do
        before(:each) do
          cards_form.temp_cards = "foo"
        end

        it "is not valid" do
          expect(cards_form).to_not be_valid
        end
      end

      context "when a temp_cards is not an integer" do
        before(:each) do
          cards_form.temp_cards = 3.14
        end

        it "is not valid" do
          expect(cards_form).to_not be_valid
        end
      end

      context "when a temp_cards is a negative number" do
        before(:each) do
          cards_form.temp_cards = -3
        end

        it "is not valid" do
          expect(cards_form).to_not be_valid
        end
      end
    end
  end

  describe "#transient_registration" do
    context "when the transient registration is invalid" do
      let(:transient_registration) do
        build(:transient_registration,
              workflow_state: "cards_form")
      end
      # Don't use FactoryBot for this as we need to make sure it initializes with a specific object
      let(:cards_form) { CardsForm.new(transient_registration) }

      before(:each) do
        # Make reg_identifier valid for the form, but not the transient object
        cards_form.reg_identifier = transient_registration.reg_identifier
        transient_registration.reg_identifier = "foo"
      end

      it "is not valid" do
        expect(cards_form).to_not be_valid
      end

      it "inherits the errors from the transient_registration" do
        cards_form.valid?
        expect(cards_form.errors[:base]).to include(I18n.t("mongoid.errors.models.transient_registration.attributes.reg_identifier.invalid_format"))
      end
    end
  end
end
