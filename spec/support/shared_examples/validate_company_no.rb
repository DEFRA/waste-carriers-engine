# frozen_string_literal: true

# Tests for fields using the CompanyNoValidator
RSpec.shared_examples "validate company_no" do |form_factory|
  before do
    allow_any_instance_of(WasteCarriersEngine::CompaniesHouseService).to receive(:status).and_return(:active)
  end

  context "when a valid transient registration exists" do
    let(:form) { build(form_factory, :has_required_data) }

    context "when a company_no meets the requirements" do
      it "is valid" do
        expect(form).to be_valid
      end
    end

    context "when a company_no is blank" do
      before do
        form.company_no = ""
      end

      it "is not valid" do
        expect(form).to_not be_valid
      end
    end

    context "when a company_no is not in a valid format" do
      before do
        form.company_no = "foo"
      end

      it "is not valid" do
        expect(form).to_not be_valid
      end
    end

    context "when a company_no is not found" do
      before do
        allow_any_instance_of(WasteCarriersEngine::CompaniesHouseService).to receive(:status).and_return(:not_found)
        form.company_no = "99999999"
      end

      it "is not valid" do
        expect(form).to_not be_valid
      end
    end

    context "when a company_no is inactive" do
      before do
        allow_any_instance_of(WasteCarriersEngine::CompaniesHouseService).to receive(:status).and_return(:inactive)
        form.company_no = "07281919"
      end

      it "is not valid" do
        expect(form).to_not be_valid
      end
    end

    context "when the business_type doesn't require a company_no" do
      before do
        registration = WasteCarriersEngine::Registration.where(reg_identifier: form.transient_registration.reg_identifier).first
        registration.update(business_type: "soleTrader")
        form.transient_registration.business_type = "soleTrader"
        form.business_type = "soleTrader"
      end

      context "when the company_no is not blank" do
        it "is valid" do
          expect(form).to be_valid
        end
      end

      context "when the company_no is blank" do
        before do
          form.company_no = ""
        end

        it "is valid" do
          expect(form).to be_valid
        end
      end
    end
  end
end
