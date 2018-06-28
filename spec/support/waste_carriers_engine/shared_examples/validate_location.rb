# Tests for fields using the LocationValidator
RSpec.shared_examples "validate location" do |form_factory|
  context "when a valid transient registration exists" do
    let(:form) { build(form_factory, :has_required_data) }

    context "when a location meets the requirements" do
      it "is valid" do
        expect(form).to be_valid
      end
    end

    context "when a location is blank" do
      before(:each) do
        form.location = ""
      end

      it "is not valid" do
        expect(form).to_not be_valid
      end
    end

    context "when a location is not in the allowed list" do
      before(:each) do
        form.location = "foo"
      end

      it "is not valid" do
        expect(form).to_not be_valid
      end
    end
  end
end
