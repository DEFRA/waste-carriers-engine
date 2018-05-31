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

  describe "set_up_payment_link" do
    context "when the request is valid" do
      let(:root) { Rails.configuration.wcrs_renewals_url }
      let(:reg_id) { transient_registration.reg_identifier }

      it "returns a link" do
        VCR.use_cassette("worldpay_initial_request") do
          link = "https://secure-test.worldpay.com/wcc/dispatcher?OrderKey="
          expect(worldpay_service.set_up_payment_link).to include(link)
        end
      end

      it "includes the success URL" do
        VCR.use_cassette("worldpay_initial_request") do
          success_url = "&successURL=" + CGI.escape("#{root}/worldpay/success/#{reg_id}")
          expect(worldpay_service.set_up_payment_link).to include(success_url)
        end
      end

      it "includes the pending URL" do
        VCR.use_cassette("worldpay_initial_request") do
          pending_url = "&pendingURL=" + CGI.escape("#{root}/worldpay/failure/#{reg_id}")
          expect(worldpay_service.set_up_payment_link).to include(pending_url)
        end
      end

      it "includes the failure URL" do
        VCR.use_cassette("worldpay_initial_request") do
          failure_url = "&failureURL=" + CGI.escape("#{root}/worldpay/failure/#{reg_id}")
          expect(worldpay_service.set_up_payment_link).to include(failure_url)
        end
      end

      it "includes the cancel URL" do
        VCR.use_cassette("worldpay_initial_request") do
          cancel_url = "&cancelURL=" + CGI.escape("#{root}/worldpay/failure/#{reg_id}")
          expect(worldpay_service.set_up_payment_link).to include(cancel_url)
        end
      end

      it "includes the error URL" do
        VCR.use_cassette("worldpay_initial_request") do
          error_url = "&errorURL=" + CGI.escape("#{root}/worldpay/failure/#{reg_id}")
          expect(worldpay_service.set_up_payment_link).to include(error_url)
        end
      end
    end

    context "when the request is invalid" do
      before do
        allow_any_instance_of(WorldpayXmlService).to receive(:build_xml).and_return("foo")
      end

      it "returns :error" do
        VCR.use_cassette("worldpay_initial_request_invalid") do
          expect(worldpay_service.set_up_payment_link).to eq(:error)
        end
      end
    end
  end
end
