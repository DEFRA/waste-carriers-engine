# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe EditCompletionService do
    let(:copyable_attributes) do
      {
        # Don't include all attributes - we just need to have some examples
        "addresses" => {},
        "contact_email" => nil,
        "keyPeople" => {}
      }
    end
    let(:uncopyable_attributes) do
      {
        "_id" => nil,
        "token" => nil,
        "account_email" => nil,
        "created_at" => nil,
        "financeDetails" => nil,
        "temp_cards" => nil,
        "temp_company_postcode" => nil,
        "temp_contact_postcode" => nil,
        "temp_os_places_error" => nil,
        "temp_payment_method" => nil,
        "temp_tier_check" => nil,
        "_type" => nil,
        "workflow_state" => nil
      }
    end
    let(:attributes) do
      copyable_attributes.merge(uncopyable_attributes)
    end

    let(:first_name) { "Foo" }
    let(:last_name) { "Bar" }
    let(:contact_address) { double(:address) }

    let(:registration) { double(:edit_registration) }
    let(:edit_registration) do
      double(:edit_registration,
             attributes: attributes,
             registration: registration,
             contact_address: contact_address,
             first_name: first_name,
             last_name: last_name)
    end

    describe ".run" do
      context "when given an edit_registration" do
        it "updates the registration and deletes the edit_registration" do
          # Sets up the contact address data
          expect(contact_address).to receive(:first_name=).with(first_name)
          expect(contact_address).to receive(:last_name=).with(last_name)
          # Updates the registration
          expect(registration).to receive(:write_attributes).with(copyable_attributes)
          expect(registration).to receive(:save!)
          # Deletes transient registration
          expect(edit_registration).to receive(:delete)

          described_class.run(edit_registration: edit_registration)
        end
      end
    end
  end
end
