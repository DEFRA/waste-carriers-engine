# frozen_string_literal: true

RSpec.shared_examples "company_address_manual_form workflow" do |factory:|
  describe "#workflow_state" do
    context "when the registration is upper tier" do
      let(:tier) { WasteCarriersEngine::Registration::UPPER_TIER }

      context "when the user has opted to provide a trading name" do
        let(:temp_use_trading_name) { "yes" }

        it_behaves_like "a manual address transition",
                        next_state: :declare_convictions_form,
                        address_type: "company",
                        factory: factory
      end

      context "when the user has opted to not provide a trading name" do
        let(:temp_use_trading_name) { "no" }

        it_behaves_like "a manual address transition",
                        next_state: :declare_convictions_form,
                        address_type: "company",
                        factory: factory
      end
    end

    context "when the registration is lower tier" do
      let(:tier) { WasteCarriersEngine::Registration::LOWER_TIER }

      context "when the user has opted to provide a trading name" do
        let(:temp_use_trading_name) { "yes" }

        it_behaves_like "a manual address transition",
                        next_state: :contact_name_form,
                        address_type: "company",
                        factory: factory
      end

      context "when the user has opted to not provide a trading name" do
        let(:temp_use_trading_name) { "no" }

        it_behaves_like "a manual address transition",
                        next_state: :contact_name_form,
                        address_type: "company",
                        factory: factory
      end
    end

    describe "#workflow_state" do
      context ":company_address_manual_form state transitions" do
        context "on next" do
          context "when the registration is a lower tier" do
            subject { build(:new_registration, :lower, workflow_state: "company_address_manual_form") }

            include_examples "has next transition", next_state: "contact_name_form"
          end
        end
      end
    end
  end
end
