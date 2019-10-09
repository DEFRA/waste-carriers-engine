# frozen_string_literal: true

# Tests for fields using the YesNoValidator
RSpec.shared_examples "validate yes no" do |form_factory, field|
  context "when a valid transient registration exists" do
    let(:form) { build(form_factory, :has_required_data) }

    before do
      # Using 'send' because we have to pass in a field name (for example, instead of form.value = ?)
      # TODO: Temporary refactoring code
      if form.respond_to? "#{field}="
        form.send("#{field}=", yes_or_no_value)
      else
        form.transient_registration.send("#{field}=", yes_or_no_value)
      end
    end

    context "when a value is yes" do
      let(:yes_or_no_value) { "yes" }

      it "is valid" do
        expect(form).to be_valid
      end
    end

    context "when a value is no" do
      let(:yes_or_no_value) { "no" }

      it "is valid" do
        expect(form).to be_valid
      end
    end

    context "when a value is not a valid string" do
      let(:yes_or_no_value) { "foo" }

      it "is not valid" do
        expect(form).to_not be_valid
      end
    end

    context "when a value is blank" do
      let(:yes_or_no_value) { "" }

      it "is not valid" do
        expect(form).to_not be_valid
      end
    end

    context "when a value is nil" do
      let(:yes_or_no_value) { nil }

      it "is not valid" do
        expect(form).to_not be_valid
      end
    end
  end
end
