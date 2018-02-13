require "rails_helper"

RSpec.describe CompanyAddressManualForm, type: :model do
  describe "#submit" do
    context "when the form is valid" do
      let(:company_address_manual_form) { build(:company_address_manual_form, :has_required_data) }
      let(:valid_params) do
        {
          reg_identifier: company_address_manual_form.reg_identifier,
          house_number: company_address_manual_form.house_number,
          address_line_1: company_address_manual_form.address_line_1,
          address_line_2: company_address_manual_form.address_line_2,
          town_city: company_address_manual_form.town_city,
          postcode: company_address_manual_form.postcode,
          country: company_address_manual_form.country
        }
      end

      it "should submit" do
        expect(company_address_manual_form.submit(valid_params)).to eq(true)
      end
    end

    context "when the form is not valid" do
      let(:company_address_manual_form) { build(:company_address_manual_form, :has_required_data) }
      let(:invalid_params) { { reg_identifier: "foo" } }

      it "should not submit" do
        expect(company_address_manual_form.submit(invalid_params)).to eq(false)
      end
    end
  end

  context "when a valid transient registration exists" do
    let(:company_address_manual_form) { build(:company_address_manual_form, :has_required_data) }

    context "when everything meets the requirements" do
      it "is valid" do
        expect(company_address_manual_form).to be_valid
      end
    end

    describe "#reg_identifier" do
      context "when a reg_identifier is blank" do
        before(:each) do
          company_address_manual_form.reg_identifier = ""
        end

        it "is not valid" do
          expect(company_address_manual_form).to_not be_valid
        end
      end
    end

    describe "#country" do
      context "when the country is blank" do
        before(:each) do
          company_address_manual_form.country = nil
        end

        context "when the business_type is not overseas" do
          before(:each) do
            company_address_manual_form.business_type = "limitedCompany"
          end

          it "is valid" do
            expect(company_address_manual_form).to be_valid
          end
        end

        context "when the business_type is overseas" do
          before(:each) do
            company_address_manual_form.business_type = "overseas"
          end

          it "is not valid" do
            expect(company_address_manual_form).to_not be_valid
          end
        end
      end
    end
  end

  describe "#transient_registration" do
    context "when the transient registration is invalid" do
      let(:transient_registration) do
        build(:transient_registration,
              workflow_state: "company_address_manual_form")
      end
      # Don't use FactoryBot for this as we need to make sure it initializes with a specific object
      let(:company_address_manual_form) { CompanyAddressManualForm.new(transient_registration) }

      before(:each) do
        # Make reg_identifier valid for the form, but not the transient object
        company_address_manual_form.reg_identifier = transient_registration.reg_identifier
        transient_registration.reg_identifier = "foo"
      end

      it "is not valid" do
        expect(company_address_manual_form).to_not be_valid
      end

      it "inherits the errors from the transient_registration" do
        company_address_manual_form.valid?
        expect(company_address_manual_form.errors[:base]).to include(I18n.t("mongoid.errors.models.transient_registration.attributes.reg_identifier.invalid_format"))
      end
    end
  end
end
