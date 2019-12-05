# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe CompanyAddressForm, type: :model do
    before do
      stub_address_finder_service(uprn: "340116")
    end

    describe "#submit" do
      context "when the form is valid" do
        let(:company_address_form) { build(:company_address_form, :has_required_data) }
        let(:valid_params) do
          {
            token: company_address_form.token,
            company_address: {
              uprn: "340116"
            }
          }
        end

        it "should submit" do
          expect(company_address_form.submit(valid_params)).to eq(true)
        end
      end

      context "when the form is not valid" do
        let(:company_address_form) { build(:company_address_form, :has_required_data) }
        let(:invalid_params) { { token: "foo" } }

        it "should not submit" do
          expect(company_address_form.submit(invalid_params)).to eq(false)
        end
      end
    end

    context "when a form with a valid transient registration exists" do
      let(:company_address_form) { build(:company_address_form, :has_required_data) }

      describe "#addresses" do
        context "when no address is selected" do
          before(:each) do
            company_address_form.transient_registration.addresses = nil
          end

          it "is not valid" do
            expect(company_address_form).to_not be_valid
          end
        end
      end
    end

    context "when a form with a valid transient registration exists and the transient registration already has an address" do
      let(:transient_registration) do
        build(:renewing_registration,
              :has_postcode,
              :has_addresses,
              workflow_state: "company_address_form")
      end
      # Don't use FactoryBot for this as we need to make sure it initializes with a specific object
      let(:company_address_form) { CompanyAddressForm.new(transient_registration) }

      describe "#temp_address" do
        it "pre-selects the address" do
          expect(company_address_form.company_address.uprn.to_s).to eq(transient_registration.addresses.where(address_type: "REGISTERED").first.uprn.to_s)
        end
      end
    end
  end
end
