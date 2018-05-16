require "rails_helper"

RSpec.describe ContactNameForm, type: :model do
  describe "#submit" do
    context "when the form is valid" do
      let(:contact_name_form) { build(:contact_name_form, :has_required_data) }
      let(:valid_params) do
        {
          reg_identifier: contact_name_form.reg_identifier,
          first_name: contact_name_form.first_name,
          last_name: contact_name_form.last_name
        }
      end

      it "should submit" do
        expect(contact_name_form.submit(valid_params)).to eq(true)
      end
    end

    context "when the form is not valid" do
      let(:contact_name_form) { build(:contact_name_form, :has_required_data) }
      let(:invalid_params) { { reg_identifier: "foo" } }

      it "should not submit" do
        expect(contact_name_form.submit(invalid_params)).to eq(false)
      end
    end
  end

  context "when a valid transient registration exists" do
    let(:contact_name_form) { build(:contact_name_form, :has_required_data) }

    context "when everything meets the requirements" do
      it "is valid" do
        expect(contact_name_form).to be_valid
      end
    end

    describe "#first_name" do
      context "when a first_name is blank" do
        before(:each) do
          contact_name_form.first_name = ""
        end

        it "is not valid" do
          expect(contact_name_form).to_not be_valid
        end
      end

      context "when a first_name is too long" do
        before(:each) do
          contact_name_form.first_name = "0fJQLDxvB77dz3SbcMDSH60kM82VUUMOlpZBkIUnh1IIUE0zF4r3NbHotPIzlbeQdCWB1qa"
        end

        it "is not valid" do
          expect(contact_name_form).to_not be_valid
        end
      end

      context "when a first_name contains invalid characters" do
        before(:each) do
          contact_name_form.first_name = "W@ste"
        end

        it "is not valid" do
          expect(contact_name_form).to_not be_valid
        end
      end
    end

    describe "#last_name" do
      context "when a last_name is blank" do
        before(:each) do
          contact_name_form.last_name = ""
        end

        it "is not valid" do
          expect(contact_name_form).to_not be_valid
        end
      end

      context "when a last_name is too long" do
        before(:each) do
          contact_name_form.last_name = "0fJQLDxvB77dz3SbcMDSH60kM82VUUMOlpZBkIUnh1IIUE0zF4r3NbHotPIzlbeQdCWB1qa"
        end

        it "is not valid" do
          expect(contact_name_form).to_not be_valid
        end
      end

      context "when a last_name contains invalid characters" do
        before(:each) do
          contact_name_form.last_name = "C@rrier"
        end

        it "is not valid" do
          expect(contact_name_form).to_not be_valid
        end
      end
    end
  end
end
