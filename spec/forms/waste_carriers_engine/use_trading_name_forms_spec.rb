# frozen_string_literal: true

require "rails_helper"
require "defra_ruby_companies_house"

module WasteCarriersEngine
  RSpec.describe UseTradingNameForm, type: :model do

    describe "#submit" do
      let(:use_trading_name_form) { build(:use_trading_name_form, :new_registration, :has_required_data) }

      context "when the form is valid" do
        subject(:submitted_form) { use_trading_name_form.submit(valid_params) }

        context "when the user selects yes" do
          let(:valid_params) { { token: use_trading_name_form.token, temp_use_trading_name: "yes" } }
          let(:transient_registration) { use_trading_name_form.transient_registration }

          it "submits the form" do
            expect(submitted_form).to be_truthy
          end

          it "updates the transient registration" do
            expect { submitted_form }.to change { transient_registration.reload.attributes["temp_use_trading_name"] }.to("yes")
          end
        end

        context "when the user selects no" do
          let(:valid_params) { { token: use_trading_name_form.token, temp_use_trading_name: "no" } }

          it "submits the form" do
            expect(submitted_form).to be_truthy
          end
        end
      end

      context "when the form is not valid" do
        before do
          allow(use_trading_name_form).to receive(:valid?).and_return(false)
        end

        it "does not submit the form" do
          expect(use_trading_name_form.submit({})).to be_falsey
        end
      end
    end

    include_examples "validate yes no", :use_trading_name_form, :temp_use_trading_name
  end
end
