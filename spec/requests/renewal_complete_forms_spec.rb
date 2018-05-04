require "rails_helper"

RSpec.describe "RenewalCompleteForms", type: :request do
  include_examples "GET locked-in form", form = "renewal_complete_form"
end
