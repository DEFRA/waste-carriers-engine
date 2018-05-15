# Tests for fields using the PhoneNumberValidator
RSpec.shared_examples "validate phone_number" do |form_factory|
  context "when a valid transient registration exists" do
    let(:form) { build(form_factory, :has_required_data) }

    context "when a phone_number meets the requirements" do
      it "is valid" do
        expect(form).to be_valid
      end
    end

    context "when a UK phone_number is formatted to include +44" do
      before(:each) do
        form.phone_number = "+44 1234 567890"
      end

      it "is valid" do
        expect(form).to be_valid
      end
    end

    context "when a phone_number is a valid international number" do
      before(:each) do
        form.phone_number = "+1-202-555-0109"
      end

      it "is valid" do
        expect(form).to be_valid
      end
    end

    context "when a phone_number is blank" do
      before(:each) do
        form.phone_number = ""
      end

      it "is not valid" do
        expect(form).to_not be_valid
      end
    end

    context "when a phone_number is too long" do
      before(:each) do
        form.phone_number = "01234 567 890 123"
      end

      it "is not valid" do
        expect(form).to_not be_valid
      end
    end

    context "when a phone_number is not a number" do
      before(:each) do
        form.phone_number = "foo"
      end

      it "is not valid" do
        expect(form).to_not be_valid
      end
    end

    context "when phone_number is not a valid number" do
      before(:each) do
        # It might look valid, but actually this is not a recognised number
        form.phone_number = "0117 785 3149"
      end

      it "is not valid" do
        expect(form).to_not be_valid
      end
    end
  end
end
