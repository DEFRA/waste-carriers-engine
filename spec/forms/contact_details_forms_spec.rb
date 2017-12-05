require "rails_helper"

RSpec.describe ContactDetailsForm, type: :model do
  describe "#first_name" do
    context "when a valid registration exists" do
      let(:contact_details_form) { build(:contact_details_form, :has_required_data) }

      context "when a first_name meets the requirements" do
        before(:each) do
          contact_details_form.first_name = "Valid"
        end

        it "is valid" do
          expect(contact_details_form).to be_valid
        end
      end

      context "when a first_name is blank" do
        before(:each) do
          contact_details_form.first_name = ""
        end

        it "is not valid" do
          expect(contact_details_form).to_not be_valid
        end
      end
    end
  end

  describe "#last_name" do
    context "when a valid registration exists" do
      let(:contact_details_form) { build(:contact_details_form, :has_required_data) }

      context "when a last_name meets the requirements" do
        before(:each) do
          contact_details_form.last_name = "Valid"
        end

        it "is valid" do
          expect(contact_details_form).to be_valid
        end
      end

      context "when a last_name is blank" do
        before(:each) do
          contact_details_form.last_name = ""
        end

        it "is not valid" do
          expect(contact_details_form).to_not be_valid
        end
      end
    end
  end

  describe "#phone_number" do
    context "when a valid registration exists" do
      let(:contact_details_form) { build(:contact_details_form, :has_required_data) }

      context "when a phone_number meets the requirements" do
        before(:each) do
          contact_details_form.phone_number = "01234 567890"
        end

        it "is valid" do
          expect(contact_details_form).to be_valid
        end
      end

      context "when a phone_number is blank" do
        before(:each) do
          contact_details_form.phone_number = ""
        end

        it "is not valid" do
          expect(contact_details_form).to_not be_valid
        end
      end
    end
  end

  describe "#contact_email" do
    context "when a valid registration exists" do
      let(:contact_details_form) { build(:contact_details_form, :has_required_data) }

      context "when a contact_email meets the requirements" do
        before(:each) do
          contact_details_form.contact_email = "valid@example.com"
        end

        it "is valid" do
          expect(contact_details_form).to be_valid
        end
      end

      context "when a contact_email is blank" do
        before(:each) do
          contact_details_form.contact_email = ""
        end

        it "is not valid" do
          expect(contact_details_form).to_not be_valid
        end
      end
    end
  end
end
