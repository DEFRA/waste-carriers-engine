# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "DeregisterCompleteForms" do

    let(:transient_registration) { create(:deregistering_registration, workflow_state: "deregistration_complete_form") }
    let(:original_registration) { transient_registration.registration }

    describe "GET new_deregister_complete_form_path" do
      it "loads the form" do
        get new_deregistration_complete_form_path(transient_registration.token)

        expect(response).to render_template("deregistration_complete_forms/new")
      end
    end
  end
end
