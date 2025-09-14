# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "SuppressParameterLogging" do

    before do
      allow(Rails.logger).to receive(:info).and_call_original ### this to enable output to test.log
    end

    it "does not suppress logging for routes not specified for suppression" do
      post new_start_form_path(token: "foo"), params: { temp_site_postcode: "BS1 5AH" }

      expect(Rails.logger).to have_received(:info).with(/Parameters: .*temp_site_postcode.*BS1 5AH/)
    end

    it "suppresses logging for a route specified for suppression" do
      post process_govpay_webhook_path, params: { foo: :bar }

      expect(Rails.logger).not_to have_received(:info).with(/Parameters:/)
    end
  end
end
