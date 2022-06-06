# frozen_string_literal: true

RSpec.shared_examples "company_name_form workflow" do |factory:|
  subject { build(factory, workflow_state: "company_name_form") }

  describe "#workflow_state" do
    context ":company_name_form state transitions" do
      context "on next" do
        include_examples "has next transition", next_state: "company_postcode_form"

        context "when the business is based overseas" do
          subject { build(factory, workflow_state: "company_name_form", location: "overseas") }

          include_examples "has next transition", next_state: "company_address_manual_form"
        end
      end
    end
  end
end
