require "rails_helper"

module WasteCarriersEngine
  RSpec.describe ContactPostcodeForm, type: :model do
    before do
      example_json = { postcode: "BS1 5AH" }
      allow_any_instance_of(AddressFinderService).to receive(:search_by_postcode).and_return(example_json)
    end

    describe "#submit" do
      context "when the form is valid" do
        let(:contact_postcode_form) { build(:contact_postcode_form, :has_required_data) }
        let(:valid_params) { { reg_identifier: contact_postcode_form.reg_identifier, temp_contact_postcode: "BS1 5AH" } }

        it "should submit" do
          expect(contact_postcode_form.submit(valid_params)).to eq(true)
        end

        context "when the postcode is lowercase" do
          before(:each) do
            valid_params[:temp_contact_postcode] = "bs1 6ah"
          end

          it "upcases it" do
            contact_postcode_form.submit(valid_params)
            expect(contact_postcode_form.temp_contact_postcode).to eq("BS1 6AH")
          end
        end

        context "when the postcode has trailing spaces" do
          before(:each) do
            valid_params[:temp_contact_postcode] = "BS1 6AH      "
          end

          it "removes them" do
            contact_postcode_form.submit(valid_params)
            expect(contact_postcode_form.temp_contact_postcode).to eq("BS1 6AH")
          end
        end
      end

      context "when the form is not valid" do
        let(:contact_postcode_form) { build(:contact_postcode_form, :has_required_data) }
        let(:invalid_params) { { reg_identifier: "foo" } }

        it "should not submit" do
          expect(contact_postcode_form.submit(invalid_params)).to eq(false)
        end
      end
    end

    include_examples "validate postcode", form = :contact_postcode_form, field = :temp_contact_postcode
  end
end
