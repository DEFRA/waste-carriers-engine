# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe ContactAddressForm do
    before do
      stub_address_finder_service(uprn: "340116")
    end

    describe "#submit" do
      context "when the form is valid" do

        let(:contact_address_form) { build(:contact_address_form, :has_required_data) }
        let(:valid_params) do
          {
            token: contact_address_form.token,
            contact_address: {
              uprn: "340116"
            }
          }
        end

        it "submits" do
          expect(contact_address_form.submit(valid_params)).to be true
        end
      end

      context "when the form is not valid" do
        let(:contact_address_form) { build(:contact_address_form, :has_required_data) }
        let(:invalid_params) { { token: "foo" } }

        it "does not submit" do
          expect(contact_address_form.submit(invalid_params)).to be false
        end
      end
    end

    context "when a form with a valid transient registration exists" do
      let(:contact_address_form) { build(:contact_address_form, :has_required_data) }

      describe "#addresses" do
        context "when no address is selected" do
          before do
            contact_address_form.transient_registration.addresses = nil
          end

          it "is not valid" do
            expect(contact_address_form).not_to be_valid
          end
        end
      end
    end
  end
end
