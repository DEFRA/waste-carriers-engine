# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "DeregisterCompletionForms" do
    let(:token) { "X123" }

    before do
      create(:registration, :has_required_data,
             deregistration_token: token, deregistration_token_created_at: 3.days.ago)
    end

    it "loads the requested page" do
      get new_deregistration_confirmation_form_path(token)

      expect(response).to render_template("waste_carriers_engine/deregistration_confirmation_forms/new")
    end
  end
end
