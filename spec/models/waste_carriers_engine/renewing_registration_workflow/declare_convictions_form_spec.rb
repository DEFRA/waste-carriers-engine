# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewingRegistration do
    subject do
      build(:renewing_registration,
            :has_required_data,
            declared_convictions: declared_convictions,
            workflow_state: "declare_convictions_form")
    end
    let(:declared_convictions) { nil }

    describe "#workflow_state" do
      context "with :declare_convictions_form state transitions" do
        context "with :next transition" do

          context "when declared_convictions is yes" do
            let(:declared_convictions) { "yes" }

            it_behaves_like "has next transition", next_state: "conviction_details_form"
          end

          context "when declared_convictions is no" do
            let(:declared_convictions) { "no" }

            it_behaves_like "has next transition", next_state: "contact_name_form"
          end
        end
      end
    end
  end
end
