require "rails_helper"

RSpec.describe WorldpayForm, type: :model do
  describe "#submit" do
    context "when the form is valid" do
      let(:worldpay_form) { build(:worldpay_form, :has_required_data) }
      let(:valid_params) { { reg_identifier: worldpay_form.reg_identifier } }

      it "should submit" do
        expect(worldpay_form.submit(valid_params)).to eq(true)
      end
    end

    context "when the form is not valid" do
      let(:worldpay_form) { build(:worldpay_form, :has_required_data) }
      let(:invalid_params) { { reg_identifier: "foo" } }

      it "should not submit" do
        expect(worldpay_form.submit(invalid_params)).to eq(false)
      end
    end
  end
end
