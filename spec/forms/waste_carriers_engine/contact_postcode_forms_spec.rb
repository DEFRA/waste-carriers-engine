# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe ContactPostcodeForm do
    before do
      stub_address_finder_service
    end

    describe "#submit" do
      context "when the form is valid" do
        let(:contact_postcode_form) { build(:contact_postcode_form, :has_required_data) }
        let(:valid_params) { { token: contact_postcode_form.token, temp_contact_postcode: "BS1 5AH" } }

        it "submits" do
          expect(contact_postcode_form.submit(valid_params)).to be true
        end

        context "when the postcode is lowercase" do
          before do
            valid_params[:temp_contact_postcode] = "bs1 6ah"
          end

          it "upcases it" do
            contact_postcode_form.submit(valid_params)
            expect(contact_postcode_form.temp_contact_postcode).to eq("BS1 6AH")
          end
        end

        context "when the postcode has trailing spaces" do
          before do
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
        let(:invalid_params) { { token: "foo" } }

        it "does not submit" do
          expect(contact_postcode_form.submit(invalid_params)).to be false
        end
      end
    end

    it_behaves_like "validate postcode", :contact_postcode_form, :temp_contact_postcode
  end
end
