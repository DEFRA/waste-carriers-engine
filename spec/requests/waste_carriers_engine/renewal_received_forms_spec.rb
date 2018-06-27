require "rails_helper"

RSpec.describe "RenewalReceivedForms", type: :request do
  include_examples "GET locked-in form", form = "renewal_received_form"
end
