# frozen_string_literal: true

require "rails_helper"
require "defra_ruby_companies_house"

module WasteCarriersEngine
  RSpec.describe "RenewalInformationForms", type: :request do
    let(:defra_ruby_companies_house) { instance_double(DefraRubyCompaniesHouse) }

    before do
      allow(DefraRubyCompaniesHouse).to receive(:new).and_return(defra_ruby_companies_house)
      allow(defra_ruby_companies_house).to receive(:company_status).and_return("active")
    end

    include_examples "GET flexible form", "renewal_information_form"

    include_examples "POST without params form", "renewal_information_form"
  end
end
