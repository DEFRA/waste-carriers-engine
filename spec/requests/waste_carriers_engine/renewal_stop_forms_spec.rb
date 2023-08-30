# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "RenewalStopForms" do
    include_examples "GET flexible form", "renewal_stop_form"
  end
end
