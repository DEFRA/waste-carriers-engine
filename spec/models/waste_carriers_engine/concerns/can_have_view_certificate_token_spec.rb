# frozen_string_literal: true

require "rails_helper"

class RegistrableTest
  include WasteCarriersEngine::CanHaveViewCertificateToken
end

module WasteCarriersEngine
  RSpec.describe "CanHaveViewCertificateToken" do

    subject(:registrable) { RegistrableTest.new }

    describe "#generate_view_certificate_token!" do
      it "generates a token" do
        expect { registrable.generate_view_certificate_token! }.to change(registrable, :view_certificate_token).from(nil)
      end

      it "sets the token timestamp" do
        expect { registrable.generate_view_certificate_token! }.to change(registrable, :view_certificate_token_created_at).from(nil)
      end

      it "returns the token" do
        expect(registrable.generate_view_certificate_token!).to eq(registrable.view_certificate_token)
      end

      context "when the token has already been generated" do
        it "updates the token" do
          registrable.generate_view_certificate_token!
          expect { registrable.generate_view_certificate_token! }.to change(registrable, :view_certificate_token)
        end

        it "updates the token timestamp" do
          registrable.generate_view_certificate_token!
          Timecop.travel(1.second.from_now)
          expect { registrable.generate_view_certificate_token! }.to change(registrable, :view_certificate_token_created_at)
        end
      end
    end

    describe "#view_certificate_token_valid?" do
      context "when the token has not been generated" do
        it "returns false" do
          expect(registrable.view_certificate_token_valid?).to be(false)
        end
      end

      context "when the token has been generated" do
        context "when no config is set in env" do
          let(:default_validity_period) { WasteCarriersEngine::CanHaveViewCertificateToken::DEFAULT_TOKEN_VALIDITY_PERIOD }

          before do
            registrable.generate_view_certificate_token!
          end

          context "when the token has expired" do
            it "returns false" do
              registrable.view_certificate_token_created_at = (default_validity_period + 1).days.ago
              expect(registrable.view_certificate_token_valid?).to be(false)
            end
          end

          context "when the token has not expired" do
            it "returns true" do
              registrable.view_certificate_token_created_at = (default_validity_period - 1).days.ago
              expect(registrable.view_certificate_token_valid?).to be(true)
            end
          end
        end
      end

      context "when WCRS_VIEW_CERTIFICATE_TOKEN_VALIDITY_PERIOD set in env" do
        let(:token_validity_period) { 5 }

        before do
          stub_const("ENV", ENV.to_hash.merge("WCRS_VIEW_CERTIFICATE_TOKEN_VALIDITY_PERIOD" => token_validity_period.to_s))
          registrable.generate_view_certificate_token!
        end

        context "when the token has expired" do
          it "returns false" do
            registrable.view_certificate_token_created_at = (token_validity_period + 1).days.ago
            expect(registrable.view_certificate_token_valid?).to be(false)
          end
        end

        context "when the token has not expired" do
          it "returns true" do
            registrable.view_certificate_token_created_at = (token_validity_period - 1).days.ago
            expect(registrable.view_certificate_token_valid?).to be(true)
          end
        end
      end
    end
  end
end
