# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe InvalidCompanyStatusForm, type: :model do
    describe "#submit" do
      let(:form) { build(:invalid_company_status_form, :has_required_data) }

      context "when the form is valid" do
        let(:valid_params) { { token: form.token } }

        it "submits" do
          expect(form.submit(valid_params)).to be_truthy
        end
      end

      context "when the form is not valid" do
        before do
          allow(form).to receive(:valid?).and_return(false)
        end

        it "does not submit" do
          expect(form.submit({})).to be_falsey
        end
      end
    end
  end
end
