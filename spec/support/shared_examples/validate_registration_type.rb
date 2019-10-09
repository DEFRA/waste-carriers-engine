# frozen_string_literal: true

# Tests for fields using the RegistrationTypeValidator
RSpec.shared_examples "validate registration_type" do |form_factory|
  context "when a valid transient registration exists" do
    let(:form) { build(form_factory, :has_required_data) }

    context "when a registration_type meets the requirements" do
      it "is valid" do
        expect(form).to be_valid
      end
    end

    context "when a registration_type is blank" do
      before(:each) do
        # TODO: Temporary refactoring code
        if form.respond_to?(:registration_type=)
          form.registration_type = ""
        else
          form.transient_registration.registration_type = ""
        end
      end

      it "is not valid" do
        expect(form).to_not be_valid
      end
    end

    context "when a registration_type is not in the allowed list" do
      before(:each) do
        # TODO: Temporary refactoring code
        if form.respond_to?(:registration_type=)
          form.registration_type = ""
        else
          form.transient_registration.registration_type = "foo"
        end
      end

      it "is not valid" do
        expect(form).to_not be_valid
      end
    end
  end
end
