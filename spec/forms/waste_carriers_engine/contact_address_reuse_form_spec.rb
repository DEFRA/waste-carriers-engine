# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe ContactAddressReuseForm do
    describe "#submit" do
      let(:contact_address_reuse_form) { build(:contact_address_reuse_form) }

      context "when the form is valid" do
        let(:valid_params) { { temp_reuse_registered_address: "no" } }

        it "submits" do
          expect(contact_address_reuse_form.submit(valid_params)).to be true
        end
      end

      context "when the form is not valid" do
        it "does not submit" do
          expect(contact_address_reuse_form.submit({})).to be false
        end
      end
    end
  end
end
