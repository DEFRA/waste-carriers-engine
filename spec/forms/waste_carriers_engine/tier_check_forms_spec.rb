require "rails_helper"

module WasteCarriersEngine
  RSpec.describe TierCheckForm, type: :model do
    describe "#submit" do
      context "when the form is valid" do
        let(:tier_check_form) { build(:tier_check_form, :has_required_data) }
        let(:valid_params) do
          {
            reg_identifier: tier_check_form.reg_identifier,
            temp_tier_check: tier_check_form.temp_tier_check
          }
        end

        it "should submit" do
          expect(tier_check_form.submit(valid_params)).to eq(true)
        end
      end

      context "when the form is not valid" do
        let(:tier_check_form) { build(:tier_check_form, :has_required_data) }
        let(:invalid_params) { { reg_identifier: "foo" } }

        it "should not submit" do
          expect(tier_check_form.submit(invalid_params)).to eq(false)
        end
      end
    end

    include_examples "validate yes no", form = :tier_check_form, field = :temp_tier_check
  end
end
