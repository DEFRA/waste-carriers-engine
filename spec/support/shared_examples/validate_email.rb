# Tests for fields using the EmailValidator
RSpec.shared_examples "validate email" do |form_factory, field|
  context "when a valid transient registration exists" do
    let(:form) { build(form_factory, :has_required_data) }

    context "when an email meets the requirements" do
      it "is valid" do
        expect(form).to be_valid
      end
    end

    context "when an email is blank" do
      before(:each) do
        # Using 'send' because we have to pass in a field name (for example, instead of form.email = ?)
        form.send("#{field}=", "")
      end

      it "is not valid" do
        expect(form).to_not be_valid
      end
    end

    context "when an email is in an incorrect format" do
      before(:each) do
        # Using 'send' because we have to pass in a field name (for example, instead of form.email = ?)
        form.send("#{field}=", "foo")
      end

      it "is not valid" do
        expect(form).to_not be_valid
      end
    end
  end
end
