# frozen_string_literal: true

RSpec.shared_examples "company_address_reuse_form workflow" do |factory:|
  describe "#workflow_state" do

    subject(:transient_registration) do
      build(
        factory,
        :has_registered_address,
        temp_reuse_registered_address: temp_reuse_registered_address,
        workflow_state: "contact_address_reuse_form"
      )
    end

    context "with :contact_address_reuse_form state transitions" do
      before { allow(WasteCarriersEngine::ContactAddressAsRegisteredAddressService).to receive(:run) }

      context "when the temp_reuse_registered_address is `yes`" do
        let(:temp_reuse_registered_address) { "yes" }

        include_examples "has next transition", next_state: "check_your_answers_form"

        it "invokes the ContactAddressAsRegisteredAddressService" do
          subject.next

          expect(WasteCarriersEngine::ContactAddressAsRegisteredAddressService)
            .to have_received(:run)
            .with(subject)
        end
      end

      context "when the temp_reuse_registered_address is `no`" do
        let(:temp_reuse_registered_address) { "no" }

        include_examples "has next transition", next_state: "contact_postcode_form"

        it "does not invoke the ContactAddressAsRegisteredAddressService" do
          subject.next

          expect(WasteCarriersEngine::ContactAddressAsRegisteredAddressService)
            .not_to have_received(:run)
        end
      end
    end
  end
end
