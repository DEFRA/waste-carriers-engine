# frozen_string_literal: true

require "rails_helper"
module WasteCarriersEngine
  RSpec.describe UnsubscribeLinkService do

    subject(:run_service) { described_class.run(registration: registration) }

    let(:registration) { create(:registration, :has_required_data) }

    describe "run" do
      before { @unsubscribe_link = run_service }

      it "returns a link to the front office" do
        expect(@unsubscribe_link).to start_with(Rails.configuration.wcrs_fo_link_domain)
      end

      it "returns a link to the unsubscribe path" do
        expect(@unsubscribe_link).to include("/unsubscribe")
      end

      it "returns a link with the correct token" do
        expect(@unsubscribe_link).to include(registration.unsubscribe_token)
      end
    end
  end
end
