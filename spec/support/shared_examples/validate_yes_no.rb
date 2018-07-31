# Tests for fields using the YesNoValidator
RSpec.shared_examples "validate yes no" do |form_factory, field|
  context "when a valid transient registration exists" do
    let(:form) { build(form_factory, :has_required_data) }

    context "when a value is yes" do
      before(:each) do
        # Using 'send' because we have to pass in a field name (for example, instead of form.value = ?)
        form.send("#{field}=", "yes")
      end

      it "is valid" do
        expect(form).to be_valid
      end
    end

    context "when a value is no" do
      before(:each) do
        # Using 'send' because we have to pass in a field name (for example, instead of form.value = ?)
        form.send("#{field}=", "no")
      end

      it "is valid" do
        expect(form).to be_valid
      end
    end

    context "when a value is not a valid string" do
      before(:each) do
        # Using 'send' because we have to pass in a field name (for example, instead of form.value = ?)
        form.send("#{field}=", "foo")
      end

      it "is not valid" do
        expect(form).to_not be_valid
      end
    end

    context "when a value is blank" do
      before(:each) do
        # Using 'send' because we have to pass in a field name (for example, instead of form.value = ?)
        form.send("#{field}=", "")
      end

      it "is not valid" do
        expect(form).to_not be_valid
      end
    end

    context "when a value is nil" do
      before(:each) do
        # Using 'send' because we have to pass in a field name (for example, instead of form.value = ?)
        form.send("#{field}=", nil)
      end

      it "is not valid" do
        expect(form).to_not be_valid
      end
    end
  end
end
