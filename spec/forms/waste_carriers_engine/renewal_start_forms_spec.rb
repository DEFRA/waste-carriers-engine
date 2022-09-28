# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewalStartForm, type: :model do
    describe "#submit" do
      let(:renewal_start_form) { build(:renewal_start_form, :has_required_data) }
      let(:valid_params) { { token: renewal_start_form.token } }

      it "submits" do
        expect(renewal_start_form.submit(valid_params)).to be true
      end
    end
  end
end
