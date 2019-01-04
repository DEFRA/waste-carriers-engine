# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe ContactPhoneForm, type: :model do
    describe "#submit" do
      context "when the form is valid" do
        let(:contact_phone_form) { build(:contact_phone_form, :has_required_data) }
        let(:valid_params) do
          {
            reg_identifier: contact_phone_form.reg_identifier,
            phone_number: contact_phone_form.phone_number
          }
        end

        it "should submit" do
          expect(contact_phone_form.submit(valid_params)).to eq(true)
        end
      end

      context "when the form is not valid" do
        let(:contact_phone_form) { build(:contact_phone_form, :has_required_data) }
        let(:invalid_params) do
          {
            reg_identifier: "foo",
            phone_number: "foo"
          }
        end

        it "should not submit" do
          expect(contact_phone_form.submit(invalid_params)).to eq(false)
        end
      end
    end

    include_examples "validate phone_number", :contact_phone_form
  end
end
