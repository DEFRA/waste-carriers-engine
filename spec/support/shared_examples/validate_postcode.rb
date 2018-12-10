# frozen_string_literal: true

# Tests for fields using the PostcodeValidator
RSpec.shared_examples "validate postcode" do |form_factory, field|
  context "when a valid transient registration exists" do
    let(:form) { build(form_factory, :has_required_data) }

    context "when a postcode meets the requirements" do
      before do
        example_json = { postcode: "BS1 5AH" }
        allow_any_instance_of(WasteCarriersEngine::AddressFinderService).to receive(:search_by_postcode).and_return(example_json)
      end

      it "is valid" do
        expect(form).to be_valid
      end
    end

    context "when a postcode is blank" do
      before do
        # Using 'send' because we have to pass in a field name (for example, instead of form.temp_company_postcode = ?)
        form.send("#{field}=", "")
      end

      it "is not valid" do
        expect(form).to_not be_valid
      end
    end

    context "when a postcode is in the wrong format" do
      before do
        # Using 'send' because we have to pass in a field name (for example, instead of form.temp_company_postcode = ?)
        form.send("#{field}=", "foo")
      end

      it "is not valid" do
        expect(form).to_not be_valid
      end
    end

    context "when a postcode has no matches" do
      before do
        allow_any_instance_of(WasteCarriersEngine::AddressFinderService).to receive(:search_by_postcode).and_return(:not_found)
      end

      it "is not valid" do
        expect(form).to_not be_valid
      end
    end

    context "when a postcode search returns an error" do
      before do
        allow_any_instance_of(WasteCarriersEngine::AddressFinderService).to receive(:search_by_postcode).and_return(:error)
      end

      it "is valid" do
        expect(form).to be_valid
      end
    end
  end
end
