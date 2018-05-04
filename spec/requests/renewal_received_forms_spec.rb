require "rails_helper"
require "support/shared_examples/request_get_locked_in_form"

RSpec.describe "RenewalReceivedForms", type: :request do
  include_examples "GET locked-in form", form = "renewal_received_form"
end
