# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe WorldpayUrlService do
    before do
      allow(Rails.configuration).to receive(:host).and_return("http://localhost:3002")
    end

    let(:transient_registration) do
      create(:renewing_registration,
             :has_required_data)
    end
    let(:_id) { transient_registration._id }
    let(:link_base) { "https://secure-test.worldpay.com/wcc/dispatcher?OrderKey=" }
    let(:worldpay_url_service) { WorldpayUrlService.new(_id, link_base) }

    describe "format_url" do
      let(:url) { worldpay_url_service.format_link }
      let(:root) { Rails.configuration.host }

      it "returns a link" do
        expect(url).to include(link_base)
      end

      it "includes the success URL" do
        success_url = "&successURL=" + CGI.escape("#{root}/#{_id}/worldpay/success")
        expect(url).to include(success_url)
      end

      it "includes the pending URL" do
        pending_url = "&pendingURL=" + CGI.escape("#{root}/#{_id}/worldpay/pending")
        expect(url).to include(pending_url)
      end

      it "includes the failure URL" do
        failure_url = "&failureURL=" + CGI.escape("#{root}/#{_id}/worldpay/failure")
        expect(url).to include(failure_url)
      end

      it "includes the cancel URL" do
        cancel_url = "&cancelURL=" + CGI.escape("#{root}/#{_id}/worldpay/cancel")
        expect(url).to include(cancel_url)
      end

      it "includes the error URL" do
        error_url = "&errorURL=" + CGI.escape("#{root}/#{_id}/worldpay/error")
        expect(url).to include(error_url)
      end
    end
  end
end
