# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "RenewalReceivedForms", type: :request do
    include_examples "GET locked-in form", "renewal_received_form"
  end
end
