# frozen_string_literal: true

# Tests for fields using the PostcodeValidator
RSpec.shared_examples "validate postcode" do |form_factory, field|

  let(:form) { build(form_factory, :has_required_data) }

  describe "form validation" do

    before { form.transient_registration.send("#{field}=", postcode_string) }

    context "when the postcode string is blank" do
      let(:postcode_string) { "" }

      it { expect(form).not_to be_valid }
    end

    context "when the postcode string is not close to valid postcode format" do
      let(:postcode_string) { "foo" }

      it { expect(form).not_to be_valid }
    end

    context "when the postcode string has leading 0 instead of O in the outcode" do
      let(:postcode_string) { "0X129TF" }

      it { expect(form).not_to be_valid }
    end

    context "when the postcode string has trailing O instead of 0 in the outcode" do
      let(:postcode_string) { "SSO 9SL" }

      it { expect(form).not_to be_valid }
    end

    context "when the postcode string has leading O instead of 0 in the incode" do
      let(:postcode_string) { "SS0 OSL" }

      it { expect(form).not_to be_valid }
    end
  end

  describe "handle EaAddressFacadeV11Service responses" do
    before { allow(DefraRuby::Address::EaAddressFacadeV11Service).to receive(:run).and_return(response) }

    context "when a postcode search returns an error" do
      let(:response) { instance_double(DefraRuby::Address::Response, successful?: false, error: "foo") }

      it { expect(form).to be_valid }
    end

    context "when a postcode search returns no matches" do
      let(:response) { instance_double(DefraRuby::Address::Response, successful?: false, error: DefraRuby::Address::NoMatchError.new) }

      it { expect(form).not_to be_valid }
    end

    context "when a postcode search returns a match" do
      let(:response) { instance_double(DefraRuby::Address::Response, results: [{ postcode: "BS1 5AH" }], successful?: true) }

      it { expect(form).to be_valid }
    end
  end
end
