# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe WasteCarriersEngine::DefraRubyGovpayHelper do
    describe ".govpay_callback_url" do
      subject(:callback_url) { described_class.govpay_callback_url(transient_registration, order) }

      let(:wcrs_mock_bo_govpay_url) { "https://wcr_123.example.gov.uk:8888/fo/mocks/govpay/v1" }
      let(:transient_registration) { create(:new_registration, :has_pending_govpay_status) }
      let(:order) { transient_registration.finance_details.orders.first }
      let(:application_host) { Rails.configuration.host }
      let(:path) do
        WasteCarriersEngine::Engine.routes.url_helpers.payment_callback_govpay_forms_path(
          token: transient_registration.token,
          uuid: order.payment_uuid
        )
      end

      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:fetch).and_call_original

        allow(ENV).to receive(:[]).with("WCRS_MOCK_ENABLED").and_return(mocks_enabled?)
        allow(ENV).to receive(:fetch).with("WCRS_MOCK_ENABLED").and_return(mocks_enabled?)

        # The functionality we are testing does not change anything under normal vagrant config
        # so we set the relevant environment variable to a different URL for test purposes.
        allow(ENV).to receive(:[]).with("WCRS_MOCK_BO_GOVPAY_URL").and_return(wcrs_mock_bo_govpay_url)
        allow(ENV).to receive(:fetch).with("WCRS_MOCK_BO_GOVPAY_URL").and_return(wcrs_mock_bo_govpay_url)
      end

      context "when mocks are not enabled" do
        let(:mocks_enabled?) { "false" }

        it { expect(callback_url).to eq "#{application_host}#{path}" }
      end

      context "when mocks are enabled" do
        let(:mocks_enabled?) { "true" }

        it do
          expect(callback_url).to eq(
            Rails.configuration.host +
            WasteCarriersEngine::Engine.routes.url_helpers.payment_callback_govpay_forms_path(
              transient_registration.token,
              order.payment_uuid
            )
          )
        end
      end
    end
  end
end
