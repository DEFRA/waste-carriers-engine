# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "RegistrationCompletedForms", type: :request do
    describe "GET new_registration_completed_form_path" do
      context "when no new registration exists" do
        it "redirects to the invalid page" do
          get new_registration_completed_form_path("wibblewobblejellyonaplate")

          expect(response).to redirect_to(page_path("invalid"))
        end
      end

      context "when a valid new registration exists" do
        let(:transient_registration) do
          create(
            :new_registration,
            :has_required_data,
            workflow_state: "registration_completed_form"
          )
        end

        context "when the new registration is a lower tier registration" do
          let(:transient_registration) do
            create(
              :new_registration,
              :has_required_lower_tier_data,
              workflow_state: "registration_completed_form"
            )
          end

          it "returns a 200 status, renders the :new template, creates a new registration and deletes the transient registration" do
            reg_identifier = transient_registration.reg_identifier
            new_registrations_count = WasteCarriersEngine::NewRegistration.count

            get new_registration_completed_form_path(transient_registration.token)

            registration = WasteCarriersEngine::Registration.find_by(reg_identifier: reg_identifier)

            expect(response).to have_http_status(:ok)
            expect(response).to render_template(:new)
            expect(registration).to be_valid
            expect(registration).to be_active
            expect(WasteCarriersEngine::NewRegistration.count).to eq(new_registrations_count - 1)
          end
        end

        context "when link_from_journeys_to_dashboards is enabled" do
          before { allow(WasteCarriersEngine.configuration).to receive(:link_from_journeys_to_dashboards).and_return(true) }

          it "includes the finished button" do
            get new_registration_completed_form_path(transient_registration.token)

            expect(response.body).to include("Finished")
          end
        end

        context "when link_from_journeys_to_dashboards is disabled" do
          before { allow(WasteCarriersEngine.configuration).to receive(:link_from_journeys_to_dashboards).and_return(false) }

          it "does not include the finished button" do
            get new_registration_completed_form_path(transient_registration.token)

            expect(response.body).not_to include("Finished")
          end
        end

        context "when the workflow_state is correct" do
          before do
            transient_registration.finance_details = build(:finance_details, :has_paid_order_and_payment)
            transient_registration.save
          end

          it "returns a 200 status, renders the :new template, creates a new registration and deletes the transient registration" do
            reg_identifier = transient_registration.reg_identifier
            new_registrations_count = WasteCarriersEngine::NewRegistration.count

            get new_registration_completed_form_path(transient_registration.token)

            registration = WasteCarriersEngine::Registration.find_by(reg_identifier: reg_identifier)

            expect(response).to have_http_status(:ok)
            expect(response).to render_template(:new)
            expect(registration).to be_valid
            expect(registration).to be_active
            expect(registration.key_people.count).to eq(1)
            expect(WasteCarriersEngine::NewRegistration.count).to eq(new_registrations_count - 1)
          end
        end

        context "when the workflow_state is not correct" do
          before do
            transient_registration.update_attributes(workflow_state: "payment_summary_form")
          end

          it "redirects to the correct page and does not creates a new registration nor delete the transient object" do
            new_registrations_count = WasteCarriersEngine::NewRegistration.count

            get new_registration_completed_form_path(transient_registration.token)

            registration_scope = WasteCarriersEngine::Registration.where(reg_identifier: transient_registration.reg_identifier)

            expect(response).to redirect_to(new_payment_summary_form_path(transient_registration.token))
            expect(WasteCarriersEngine::NewRegistration.count).to eq(new_registrations_count)
            expect(registration_scope).to be_empty
          end
        end
      end
    end
  end
end
