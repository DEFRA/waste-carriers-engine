# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "MustRegisterInWalesForms" do
    include_examples "GET flexible form", "must_register_in_wales_form"
  end
end
