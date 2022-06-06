# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "CannotRenewTypeChangeForms", type: :request do
    include_examples "GET flexible form", "cannot_renew_type_change_form"
  end
end
