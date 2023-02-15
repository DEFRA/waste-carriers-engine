# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "DeregisterConfirmationForms" do

    let(:transient_registration) { create(:deregistering_registration, workflow_state: "deregistration_confirmation_form") }
    let(:original_registration) { transient_registration.registration }
    let(:email_service) { instance_double(Notify::DeregistrationConfirmationEmailService) }

    describe "GET new_deregister_confirmation_form_path" do
      it "loads the form" do
        get new_deregistration_confirmation_form_path(transient_registration.token)

        expect(response).to render_template("deregistration_confirmation_forms/new")
      end
    end

    describe "POST deregister_confirmation_forms_path" do

      before do
        allow(Notify::DeregistrationConfirmationEmailService).to receive(:new).and_return(email_service)
        allow(email_service).to receive(:run)
      end

      subject(:submit_form) do
        post_form_with_params(:deregistration_confirmation_form,
                              transient_registration.reg_identifier,
                              { temp_confirm_deregistration: selected_option })
      end

      context "when the user confirms deregistration" do
        let(:selected_option) { "yes" }

        it "redirects to the deregistration_confirmed form" do
          submit_form

          expect(response).to redirect_to(new_deregistration_complete_form_path(transient_registration.token))
        end

        it "sets the registration status to 'INACTIVE'" do
          expect { submit_form }.to change { original_registration.reload.metaData.status }.to("INACTIVE")
        end
      end

      context "when the user declines deregistration" do
        let(:selected_option) { "no" }

        it "redirects to the start form" do
          submit_form

          expect(response).to redirect_to %r{^http://www.example.com#{new_start_form_path}}
        end

        it "does not change the registration status" do
          expect { submit_form }.not_to change { original_registration.reload.metaData.status }
        end
      end

      context "when the user does not select an option" do
        let(:selected_option) { nil }

        it "raises an error" do
          submit_form

          expect(response.body).to include("You must select yes or no")
        end
      end
    end
  end
end
