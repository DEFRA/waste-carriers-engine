# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "RenewalReceivedPendingConvictionForms" do
    it_behaves_like "GET locked-in form", "renewal_received_pending_conviction_form"
  end
end
