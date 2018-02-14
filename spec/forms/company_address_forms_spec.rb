require "rails_helper"

RSpec.describe CompanyAddressForm, type: :model do
  # Stub the address search so we have JSON to use
  before do
    address_json = build(:company_address_form, :has_required_data).temp_addresses
    allow_any_instance_of(AddressFinderService).to receive(:search_by_postcode).and_return(address_json)
  end

  describe "#submit" do
    context "when the form is valid" do
      let(:company_address_form) { build(:company_address_form, :has_required_data) }
      let(:valid_params) { { reg_identifier: company_address_form.reg_identifier, temp_address: company_address_form.temp_address } }

      it "should submit" do
        VCR.use_cassette("company_postcode_form_valid_postcode") do
          expect(company_address_form.submit(valid_params)).to eq(true)
        end
      end
    end

    context "when the form is not valid" do
      let(:company_address_form) { build(:company_address_form, :has_required_data) }
      let(:invalid_params) { { reg_identifier: "foo" } }

      it "should not submit" do
        VCR.use_cassette("company_postcode_form_valid_postcode") do
          expect(company_address_form.submit(invalid_params)).to eq(false)
        end
      end
    end
  end

  context "when a form with a valid transient registration exists" do
    let(:company_address_form) { build(:company_address_form, :has_required_data) }

    describe "#reg_identifier" do
      context "when a reg_identifier meets the requirements" do
        it "is valid" do
          VCR.use_cassette("company_postcode_form_valid_postcode") do
            expect(company_address_form).to be_valid
          end
        end
      end

      context "when a reg_identifier is blank" do
        before(:each) do
          company_address_form.reg_identifier = ""
        end

        it "is not valid" do
          VCR.use_cassette("company_postcode_form_valid_postcode") do
            expect(company_address_form).to_not be_valid
          end
        end
      end
    end

    describe "#addresses" do
      context "when no address is selected" do
        before(:each) do
          company_address_form.addresses = nil
        end

        it "is not valid" do
          expect(company_address_form).to_not be_valid
        end
      end
    end
  end

  context "when a form with a valid transient registration exists and the transient registration already has an address" do
    let(:transient_registration) do
      build(:transient_registration,
            :has_postcode,
            :has_addresses,
            workflow_state: "company_address_form")
    end
    # Don't use FactoryBot for this as we need to make sure it initializes with a specific object
    let(:company_address_form) { CompanyAddressForm.new(transient_registration) }

    describe "#temp_address" do
      it "pre-selects the address" do
        expect(company_address_form.temp_address).to eq(transient_registration.addresses.where(address_type: "REGISTERED").first.uprn.to_s)
      end
    end
  end

  describe "#transient_registration" do
    context "when the transient registration is invalid" do
      let(:transient_registration) do
        build(:transient_registration,
              workflow_state: "company_address_form")
      end
      # Don't use FactoryBot for this as we need to make sure it initializes with a specific object
      let(:company_address_form) { CompanyAddressForm.new(transient_registration) }

      before(:each) do
        # Make reg_identifier valid for the form, but not the transient object
        company_address_form.reg_identifier = transient_registration.reg_identifier
        transient_registration.reg_identifier = "foo"
      end

      it "is not valid" do
        expect(company_address_form).to_not be_valid
      end

      it "inherits the errors from the transient_registration" do
        company_address_form.valid?
        expect(company_address_form.errors[:base]).to include(I18n.t("mongoid.errors.models.transient_registration.attributes.reg_identifier.invalid_format"))
      end
    end
  end
end
