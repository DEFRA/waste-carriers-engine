require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "RenewalReceivedForms", type: :request do
    include_examples "GET locked-in form", form = "renewal_received_form"
  end
end
