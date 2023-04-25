# frozen_string_literal: true

# Tests for fields using the PostcodeValidator
RSpec.shared_examples "validate postcode" do |form_factory, field|
  context "when a valid transient registration exists" do
    let(:form) { build(form_factory, :has_required_data) }

    context "when a postcode meets the requirements" do
      before do
        example_json = { postcode: "BS1 5AH" }
        response = double(:response, results: [example_json], successful?: true)

        allow(DefraRuby::Address::EaAddressFacadeV11Service).to receive(:run).and_return(response)
      end

      it "is valid" do
        expect(form).to be_valid
      end
    end

    context "when a postcode is blank" do
      before do
        # Using 'send' because we have to pass in a field name (for example, instead of form.temp_company_postcode = ?)
        # TODO: Temporary refactoring code
        if form.respond_to? "#{field}="
          form.send("#{field}=", "")
        else
          form.transient_registration.send("#{field}=", "")
        end
      end

      it "is not valid" do
        expect(form).not_to be_valid
      end
    end

    context "when a postcode is in the wrong format" do
      before do
        # Using 'send' because we have to pass in a field name (for example, instead of form.temp_company_postcode = ?)
        # TODO: Temporary refactoring code
        if form.respond_to? "#{field}="
          form.send("#{field}=", "foo")
        else
          form.transient_registration.send("#{field}=", "foo")
        end
      end

      it "is not valid" do
        expect(form).not_to be_valid
      end
    end

    context "when a postcode has no matches" do
      before do
        response = double(:response, successful?: false, error: DefraRuby::Address::NoMatchError.new)

        allow(DefraRuby::Address::EaAddressFacadeV11Service).to receive(:run).and_return(response)
      end

      it "is not valid" do
        expect(form).not_to be_valid
      end
    end

    context "when a postcode search returns an error" do
      before do
        response = double(:response, successful?: false, error: "foo")

        allow(DefraRuby::Address::EaAddressFacadeV11Service).to receive(:run).and_return(response)
      end

      it "is valid" do
        expect(form).to be_valid
      end
    end
  end
end
