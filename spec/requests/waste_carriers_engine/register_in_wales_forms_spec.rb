# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "RegisterInWalesForms", type: :request do
    include_examples "GET flexible form", "register_in_wales_form"

    include_examples "POST without params form", "register_in_wales_form"
  end
end
