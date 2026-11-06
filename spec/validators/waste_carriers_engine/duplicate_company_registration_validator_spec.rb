# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe DuplicateCompanyRegistrationValidator do
    subject(:form) { RegistrationNumberForm.new(transient_registration) }

    let(:company_no) { "12345678" }

    before do
      allow(WasteCarriersEngine.configuration).to receive(:host_is_back_office?).and_return(false)
      allow(DefraRuby::Validators::CompaniesHouseService).to receive(:new).and_return(
        instance_double(DefraRuby::Validators::CompaniesHouseService, status: :active)
      )
    end

    context "with a new registration" do
      let(:transient_registration) { create(:new_registration, :has_required_data, company_no: company_no) }

      it "is valid when no existing registration" do
        expect(form).to be_valid
      end

      it "is invalid when active upper tier registration exists" do
        create(:registration, :has_required_data, :is_active, company_no: company_no, tier: "UPPER")
        expect(form).not_to be_valid
        expect(form.errors[:company_no]).to include("This company is already registered")
      end

      it "is valid when only lower tier registration exists" do
        create(:registration, :has_required_data, :is_active, :lower_tier, company_no: company_no)
        expect(form).to be_valid
      end

      it "is valid when registration is not active" do
        create(:registration, :has_required_data, :is_revoked, company_no: company_no, tier: "UPPER")
        expect(form).to be_valid
      end
    end

    context "with a renewal" do
      let(:transient_registration) { create(:renewing_registration, :has_required_data, company_no: company_no) }

      it "skips validation" do
        create(:registration, :has_required_data, :is_active, company_no: company_no, tier: "UPPER")
        expect(form).to be_valid
      end
    end

    context "when in back office" do
      let(:transient_registration) { create(:new_registration, :has_required_data, company_no: company_no) }

      before do
        allow(WasteCarriersEngine.configuration).to receive(:host_is_back_office?).and_return(true)
      end

      it "skips validation" do
        create(:registration, :has_required_data, :is_active, company_no: company_no, tier: "UPPER")
        expect(form).to be_valid
      end
    end
  end
end
