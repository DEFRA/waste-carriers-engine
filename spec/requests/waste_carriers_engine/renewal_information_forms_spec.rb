# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "RenewalInformationForms", type: :request do
    include_examples "GET flexible form", "renewal_information_form"

    include_examples "POST without params form", "renewal_information_form"
  end
end
