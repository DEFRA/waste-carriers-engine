# frozen_string_literal: true

RSpec.shared_examples "use_trading_name_form workflow" do |factory:|
  context "with :use_trading_name_form state transitions" do

    subject { build(factory, workflow_state: "use_trading_name_form", **params) }

    context "when the user selects Yes" do
      let(:params) { { temp_use_trading_name: "yes" } }

      include_examples "has next transition", next_state: "company_name_form"
    end

    context "when the user selects No" do
      let(:params) { { temp_use_trading_name: "no" } }

      context "when the business is based overseas" do
        let(:params) { { temp_use_trading_name: "no", location: "overseas" } }

        include_examples "has next transition", next_state: "company_address_manual_form"
      end

      include_examples "has next transition", next_state: "company_postcode_form"
    end
  end
end
