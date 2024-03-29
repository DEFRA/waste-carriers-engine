# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "ContactEmailForms" do
    include_examples "GET flexible form", "contact_email_form"

    describe "POST contact_email_form_path" do
      include_examples "POST renewal form",
                       "contact_email_form",
                       valid_params: { contact_email: "bar.baz@example.com", confirmed_email: "bar.baz@example.com" },
                       invalid_params: { contact_email: "bar", confirmed_email: "baz" },
                       test_attribute: :contact_email

      context "when the transient_registration is a new registration" do
        let(:transient_registration) do
          create(:new_registration, workflow_state: "contact_email_form")
        end

        include_examples "POST form",
                         "contact_email_form",
                         valid_params: { contact_email: "bar.baz@example.com", confirmed_email: "bar.baz@example.com" },
                         invalid_params: { contact_email: "bar", confirmed_email: "baz" }
      end
    end
  end
end
