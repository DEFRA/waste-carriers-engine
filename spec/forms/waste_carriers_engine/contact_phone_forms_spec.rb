# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe ContactPhoneForm do
    describe "#submit" do
      context "when the form is valid" do
        let(:contact_phone_form) { build(:contact_phone_form, :has_required_data) }
        let(:valid_params) do
          {
            token: contact_phone_form.token,
            phone_number: contact_phone_form.phone_number
          }
        end

        it "submits" do
          expect(contact_phone_form.submit(valid_params)).to be true
        end
      end

      context "when the form is not valid" do
        let(:contact_phone_form) { build(:contact_phone_form, :has_required_data) }
        let(:invalid_params) do
          {
            token: "foo",
            phone_number: "foo"
          }
        end

        it "does not submit" do
          expect(contact_phone_form.submit(invalid_params)).to be false
        end
      end
    end

    include_examples "validate phone_number", :contact_phone_form
  end
end
