# Tests for fields using the CompanyNoValidator
RSpec.shared_examples "CompanyNoValidator" do |form_factory|
  before do
    allow_any_instance_of(CompaniesHouseService).to receive(:status).and_return(:active)
  end

  context "when a valid transient registration exists" do
    let(:form) { build(form_factory, :has_required_data) }

    context "when a company_no meets the requirements" do
      it "is valid" do
        expect(form).to be_valid
      end
    end

    context "when a company_no is blank" do
      before(:each) do
        form.company_no = ""
      end

      it "is not valid" do
        expect(form).to_not be_valid
      end
    end

    context "when a company_no is not in a valid format" do
      before(:each) do
        form.company_no = "foo"
      end

      it "is not valid" do
        expect(form).to_not be_valid
      end
    end

    context "when a company_no is not found" do
      before(:each) do
        allow_any_instance_of(CompaniesHouseService).to receive(:status).and_return(:not_found)
        form.company_no = "99999999"
      end

      it "is not valid" do
        expect(form).to_not be_valid
      end
    end

    context "when a company_no is inactive" do
      before(:each) do
        allow_any_instance_of(CompaniesHouseService).to receive(:status).and_return(:inactive)
        form.company_no = "07281919"
      end

      it "is not valid" do
        expect(form).to_not be_valid
      end
    end
  end
end
