# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe CheckRegisteredCompanyNameForm, type: :model do
    describe "#submit" do
      let(:check_registered_company_name_form) { build(:check_registered_company_name_form, :has_required_data) }

      context "when the form is valid" do
        let(:valid_params) { { temp_use_registered_company_details: "yes" } }

        it "should submit" do
          expect(check_registered_company_name_form.submit(valid_params)).to eq(true)
        end
      end

      context "when the form is not valid" do
        it "should not submit" do
          expect(check_registered_company_name_form.submit({})).to eq(false)
        end
      end
    end
  end
end
