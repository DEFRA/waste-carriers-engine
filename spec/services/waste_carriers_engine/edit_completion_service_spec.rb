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
        "expires_on" => nil,
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

    let(:reg_finance_details) { double(:reg_finance_details) }
    let(:transient_finance_details) { double(:transient_finance_details) }

    let(:registration_type_changed) { false }

    let(:registration) do
      double(:registration,
             finance_details: reg_finance_details)
    end

    let(:edit_registration) do
      double(:edit_registration,
             attributes: attributes,
             registration: registration,
             contact_address: contact_address,
             first_name: first_name,
             last_name: last_name,
             finance_details: transient_finance_details,
             registration_type_changed?: registration_type_changed)
    end

    describe ".run" do
      context "when given an edit_registration" do
        it "updates the registration without merging finance details and deletes the edit_registration" do
          # Sets up the contact address data
          expect(contact_address).to receive(:first_name=).with(first_name)
          expect(contact_address).to receive(:last_name=).with(last_name)

          # Creates a past_registration
          expect(PastRegistration).to receive(:build_past_registration).with(registration, :edit)

          # Updates the registration
          expect(registration).to receive(:write_attributes).with(copyable_attributes)

          # Does not merge finance details
          expect(reg_finance_details).to_not receive(:update_balance)

          # Saves the registration
          expect(registration).to receive(:save!)

          # Deletes transient registration
          expect(edit_registration).to receive(:delete)

          described_class.run(edit_registration: edit_registration)
        end

        context "when the carrier type has changed" do
          let(:registration_type_changed) { true }

          it "updates the registration, merges finance details and deletes the edit_registration" do
            reg_orders = double(:orders)
            reg_payments = double(:payments)
            transient_order = double(:transient_order)
            transient_payment = double(:transient_payment)

            # Sets up the contact address data
            expect(contact_address).to receive(:first_name=).with(first_name)
            expect(contact_address).to receive(:last_name=).with(last_name)

            # Creates a past_registration
            expect(PastRegistration).to receive(:build_past_registration).with(registration, :edit)

            # Updates the registration
            expect(registration).to receive(:write_attributes).with(copyable_attributes)

            # Updates the balance
            expect(reg_finance_details).to receive(:update_balance)

            # Merges orders
            allow(reg_finance_details).to receive(:orders).and_return(reg_orders)
            allow(transient_finance_details).to receive(:orders).and_return([transient_order])
            expect(reg_orders).to receive(:<<).with(transient_order)

            # Merges payments
            expect(reg_finance_details).to receive(:payments).and_return(reg_payments).twice
            expect(transient_finance_details).to receive(:payments).and_return([transient_payment]).twice
            expect(reg_payments).to receive(:<<).with(transient_payment)

            # Saves the registration
            expect(registration).to receive(:save!)

            # Deletes transient registration
            expect(edit_registration).to receive(:delete)

            described_class.run(edit_registration: edit_registration)
          end
        end
      end
    end
  end
end
