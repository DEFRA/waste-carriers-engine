# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe CarrierNamePresenter do

    describe "#entity_display_name" do
      include_context "Sample registration with defaults" do
        let(:factory) { :transient_registration }
      end

      it_should_behave_like "Can present entity display name"
    end
  end
end
