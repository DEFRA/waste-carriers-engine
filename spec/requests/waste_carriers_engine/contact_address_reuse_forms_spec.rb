# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "ContactAddressReuseForms", type: :request do
    include_examples "GET flexible form", "contact_address_reuse_form"

    let(:user) { create(:user) }

    before(:each) do
      sign_in(user)
    end

    describe "POST contact_address_reuse_form_path" do
      context "When the transient_registration is a new registration" do
        let(:transient_registration) do
          create(:new_registration, workflow_state: "contact_address_reuse_form")
        end

        include_examples "POST form",
                         "contact_address_reuse_form",
                         valid_params: { temp_reuse_registered_address: "yes" },
                         invalid_params: { temp_reuse_registered_address: "" }

        context "when the contact address will be reused" do
          it "redirects to check_your_answers form" do
            post_form_with_params(
              :contact_address_reuse_form,
              transient_registration.token,
              { temp_reuse_registered_address: "yes" }
            )

            expect(response).to have_http_status(302)

            expect(response).to redirect_to(
              new_check_your_answers_form_path(transient_registration.token)
            )
          end
        end

        context "when the contact address will not be reused" do
          it "redirects to contact_address form" do
            post_form_with_params(
              :contact_address_reuse_form,
              transient_registration.token,
              { temp_reuse_registered_address: "no" }
            )

            expect(response).to have_http_status(302)

            expect(response).to redirect_to(
              new_contact_postcode_form_path(transient_registration.token)
            )
          end
        end
      end
    end
  end
end
