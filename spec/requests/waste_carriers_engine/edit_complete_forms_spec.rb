# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "EditCompleteForms", type: :request do
    describe "GET new_edit_complete_form_path" do
      context "when a valid user is signed in" do
        let(:user) { create(:user) }
        before(:each) do
          sign_in(user)
        end

        context "when no edit registration exists" do
          it "redirects to the invalid page" do
            get new_edit_complete_form_path("wibblewobblejellyonaplate")
            expect(response).to redirect_to(page_path("invalid"))
          end
        end

        context "when a valid edit registration exists" do
          let(:transient_registration) do
            create(:edit_registration,
                   workflow_state: "edit_complete_form")
          end

          context "when the workflow_state is correct" do
            it "loads the page" do
              get new_edit_complete_form_path(transient_registration.token)
              expect(response).to have_http_status(200)
            end
          end

          context "when the workflow_state is not correct" do
            before do
              transient_registration.update_attributes(workflow_state: "declaration_form")
            end

            it "redirects to the correct page" do
              get new_edit_complete_form_path(transient_registration.token)
              expect(response).to redirect_to(new_declaration_form_path(transient_registration.token))
            end
          end
        end
      end
    end
  end
end
