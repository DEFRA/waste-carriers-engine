require "rails_helper"

RSpec.describe ContactDetailsForm, type: :model do
  describe "#firstName" do
    context "when a valid registration exists" do
      let(:contactDetailsForm) { build(:contactDetailsForm, :has_required_data) }

      context "when a firstName meets the requirements" do
        before(:each) do
          contactDetailsForm.firstName = "Valid"
        end

        it "is valid" do
          expect(contactDetailsForm).to be_valid
        end
      end

      context "when a firstName is blank" do
        before(:each) do
          contactDetailsForm.firstName = ""
        end

        it "is not valid" do
          expect(contactDetailsForm).to_not be_valid
        end
      end
    end
  end

  describe "#lastName" do
    context "when a valid registration exists" do
      let(:contactDetailsForm) { build(:contactDetailsForm, :has_required_data) }

      context "when a lastName meets the requirements" do
        before(:each) do
          contactDetailsForm.lastName = "Valid"
        end

        it "is valid" do
          expect(contactDetailsForm).to be_valid
        end
      end

      context "when a lastName is blank" do
        before(:each) do
          contactDetailsForm.lastName = ""
        end

        it "is not valid" do
          expect(contactDetailsForm).to_not be_valid
        end
      end
    end
  end

  describe "#phoneNumber" do
    context "when a valid registration exists" do
      let(:contactDetailsForm) { build(:contactDetailsForm, :has_required_data) }

      context "when a phoneNumber meets the requirements" do
        before(:each) do
          contactDetailsForm.phoneNumber = "01234 567890"
        end

        it "is valid" do
          expect(contactDetailsForm).to be_valid
        end
      end

      context "when a phoneNumber is blank" do
        before(:each) do
          contactDetailsForm.phoneNumber = ""
        end

        it "is not valid" do
          expect(contactDetailsForm).to_not be_valid
        end
      end
    end
  end

  describe "#contactEmail" do
    context "when a valid registration exists" do
      let(:contactDetailsForm) { build(:contactDetailsForm, :has_required_data) }

      context "when a contactEmail meets the requirements" do
        before(:each) do
          contactDetailsForm.contactEmail = "valid@example.com"
        end

        it "is valid" do
          expect(contactDetailsForm).to be_valid
        end
      end

      context "when a contactEmail is blank" do
        before(:each) do
          contactDetailsForm.contactEmail = ""
        end

        it "is not valid" do
          expect(contactDetailsForm).to_not be_valid
        end
      end
    end
  end
end
