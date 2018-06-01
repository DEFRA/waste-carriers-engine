require "rails_helper"

RSpec.describe WorldpayService do
  let(:transient_registration) do
    create(:transient_registration,
           :has_required_data,
           :has_overseas_addresses,
           :has_finance_details,
           temp_cards: 0)
  end
  let(:order) { transient_registration.finance_details.orders.first }
  let(:worldpay_service) { WorldpayService.new(transient_registration, order) }

  describe "prepare_for_payment" do
    context "when the request is valid" do
      let(:root) { Rails.configuration.wcrs_renewals_url }
      let(:reg_id) { transient_registration.reg_identifier }
      let(:url) { worldpay_service.prepare_for_payment[:url] }

      it "returns a link" do
        VCR.use_cassette("worldpay_initial_request") do
          link_base = "https://secure-test.worldpay.com/wcc/dispatcher?OrderKey="
          expect(url).to include(link_base)
        end
      end

      it "includes the success URL" do
        VCR.use_cassette("worldpay_initial_request") do
          success_url = "&successURL=" + CGI.escape("#{root}/worldpay/success/#{reg_id}")
          expect(url).to include(success_url)
        end
      end

      it "includes the pending URL" do
        VCR.use_cassette("worldpay_initial_request") do
          pending_url = "&pendingURL=" + CGI.escape("#{root}/worldpay/failure/#{reg_id}")
          expect(url).to include(pending_url)
        end
      end

      it "includes the failure URL" do
        VCR.use_cassette("worldpay_initial_request") do
          failure_url = "&failureURL=" + CGI.escape("#{root}/worldpay/failure/#{reg_id}")
          expect(url).to include(failure_url)
        end
      end

      it "includes the cancel URL" do
        VCR.use_cassette("worldpay_initial_request") do
          cancel_url = "&cancelURL=" + CGI.escape("#{root}/worldpay/failure/#{reg_id}")
          expect(url).to include(cancel_url)
        end
      end

      it "includes the error URL" do
        VCR.use_cassette("worldpay_initial_request") do
          error_url = "&errorURL=" + CGI.escape("#{root}/worldpay/failure/#{reg_id}")
          expect(url).to include(error_url)
        end
      end

      it "creates a new payment" do
        VCR.use_cassette("worldpay_initial_request") do
          number_of_existing_payments = transient_registration.finance_details.payments.length
          worldpay_service.prepare_for_payment
          expect(transient_registration.finance_details.payments.length).to eq(number_of_existing_payments + 1)
        end
      end
    end

    context "when the request is invalid" do
      before do
        allow_any_instance_of(WorldpayXmlService).to receive(:build_xml).and_return("foo")
      end

      it "returns :error" do
        VCR.use_cassette("worldpay_initial_request_invalid") do
          expect(worldpay_service.prepare_for_payment).to eq(:error)
        end
      end
    end
  end
end
