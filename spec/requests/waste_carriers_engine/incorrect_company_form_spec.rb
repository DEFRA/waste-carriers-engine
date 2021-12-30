# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "IncorrectCompanyForms", type: :request do
    include_examples "GET flexible form", "incorrect_company_form"

    let(:transient_registration) do
      create(:new_registration, workflow_state: "incorrect_company_form")
    end

    it "has the expected links to continue" do
      get new_incorrect_company_form_path(transient_registration.token)

      expect(response.body).to match(%r{href="/">Continue})

      expect(response.body).to match(
        %r{href="/#{transient_registration.token}/registration-number">Enter a different number}
      )
    end
  end
end
