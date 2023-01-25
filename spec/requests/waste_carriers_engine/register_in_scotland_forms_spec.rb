# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "RegisterInScotlandForms" do
    include_examples "GET flexible form", "register_in_scotland_form"

    include_examples "POST without params form", "register_in_scotland_form"
  end
end
