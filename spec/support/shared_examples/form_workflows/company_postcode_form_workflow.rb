# frozen_string_literal: true

RSpec.shared_examples "company_postcode_form workflow" do |factory:|
  describe "#workflow_state" do

    context "when the user has opted to provide a trading name" do
      let(:temp_use_trading_name) { "yes" }

      it_behaves_like "a postcode transition",
                      address_type: "company",
                      factory: factory
    end

    context "when the user has opted not to provide a trading name" do
      let(:temp_use_trading_name) { "no" }

      it_behaves_like "a postcode transition",
                      address_type: "company",
                      factory: factory
    end
  end
end
