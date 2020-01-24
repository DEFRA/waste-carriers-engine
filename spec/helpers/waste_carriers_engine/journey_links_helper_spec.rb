# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe WasteCarriersEngine::JourneyLinksHelper, type: :helper do
    describe "renewal_finished_link" do
      it "returns the correct value" do
        expect(helper.renewal_finished_link).to eq("/")
      end
    end
  end
end
