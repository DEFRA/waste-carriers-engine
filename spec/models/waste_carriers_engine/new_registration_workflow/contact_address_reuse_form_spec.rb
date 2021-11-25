# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    subject(:new_registration) do
      build(
        :new_registration,
        :has_registered_address,
        temp_reuse_registered_address: temp_reuse_registered_address,
        workflow_state: "contact_address_reuse_form"
      )
    end

    context ":contact_address_reuse_form state transitions" do
      context "on next" do
        context "when the temp_reuse_registered_address is `yes`" do
          let(:temp_reuse_registered_address) { "yes" }

          include_examples "has next transition", next_state: "check_your_answers_form"

          it "invokes the ContactAddressAsRegisteredAddressService" do
            expect(WasteCarriersEngine::ContactAddressAsRegisteredAddressService)
              .to receive(:run)
              .with(subject)

            subject.next
          end
        end

        context "when the temp_reuse_registered_address is `no`" do
          let(:temp_reuse_registered_address) { "no" }

          include_examples "has next transition", next_state: "contact_postcode_form"

          it "does not invoke the ContactAddressAsRegisteredAddressService" do
            expect(WasteCarriersEngine::ContactAddressAsRegisteredAddressService)
              .not_to receive(:run)

            subject.next
          end
        end
      end
    end
  end
end
