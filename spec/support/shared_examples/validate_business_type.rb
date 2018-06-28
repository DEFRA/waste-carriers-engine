# Tests for fields using the BusinessTypeValidator
RSpec.shared_examples "validate business_type" do |form_factory|
  context "when a valid transient registration exists" do
    let(:form) { build(form_factory, :has_required_data) }

    context "when a business_type meets the requirements" do
      it "is valid" do
        expect(form).to be_valid
      end
    end

    context "when a business_type is blank" do
      before(:each) do
        form.business_type = ""
      end

      it "is not valid" do
        expect(form).to_not be_valid
      end
    end

    context "when a business_type is not in the allowed list" do
      before(:each) do
        form.business_type = "foo"
      end

      it "is not valid" do
        expect(form).to_not be_valid
      end
    end
  end
end
