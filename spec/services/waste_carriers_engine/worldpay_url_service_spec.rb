require "rails_helper"

module WasteCarriersEngine
  RSpec.describe WorldpayUrlService do
    before do
      allow(Rails.configuration).to receive(:host).and_return("http://localhost:3002")
    end

    let(:transient_registration) do
      create(:transient_registration,
             :has_required_data)
    end
    let(:reg_id) { transient_registration.reg_identifier }
    let(:link_base) { "https://secure-test.worldpay.com/wcc/dispatcher?OrderKey=" }
    let(:worldpay_url_service) { WorldpayUrlService.new(reg_id, link_base) }

    describe "format_url" do
      let(:url) { worldpay_url_service.format_link }
      let(:root) { Rails.configuration.host }

      it "returns a link" do
        expect(url).to include(link_base)
      end

      it "includes the success URL" do
        success_url = "&successURL=" + CGI.escape("#{root}/worldpay/success/#{reg_id}")
        expect(url).to include(success_url)
      end

      it "includes the pending URL" do
        pending_url = "&pendingURL=" + CGI.escape("#{root}/worldpay/pending/#{reg_id}")
        expect(url).to include(pending_url)
      end

      it "includes the failure URL" do
        failure_url = "&failureURL=" + CGI.escape("#{root}/worldpay/failure/#{reg_id}")
        expect(url).to include(failure_url)
      end

      it "includes the cancel URL" do
        cancel_url = "&cancelURL=" + CGI.escape("#{root}/worldpay/cancel/#{reg_id}")
        expect(url).to include(cancel_url)
      end

      it "includes the error URL" do
        error_url = "&errorURL=" + CGI.escape("#{root}/worldpay/error/#{reg_id}")
        expect(url).to include(error_url)
      end
    end
  end
end
