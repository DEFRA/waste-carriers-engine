# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "Errors", type: :request do
    describe "#show" do
      it "renders matching error template when one exists" do
        get error_path("401")
        expect(response).to render_template(:error_401)
      end

      it "renders generic error template when no matching error template exists" do
        get error_path("unknown")
        expect(response).to render_template(:error_generic)
      end
    end
  end
end
