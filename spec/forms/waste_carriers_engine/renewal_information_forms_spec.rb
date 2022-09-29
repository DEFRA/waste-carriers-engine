# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewalInformationForm, type: :model do
    describe "#submit" do
      let(:renewal_information_form) { build(:renewal_information_form, :has_required_data) }

      context "when the form is valid" do
        let(:valid_params) { { token: renewal_information_form.token } }

        it "submits" do
          expect(renewal_information_form.submit(valid_params)).to be true
        end
      end

      context "when the form is not valid" do
        before do
          allow(renewal_information_form).to receive(:valid?).and_return(false)
        end

        it "does not submit" do
          expect(renewal_information_form.submit({})).to be false
        end
      end
    end
  end
end
