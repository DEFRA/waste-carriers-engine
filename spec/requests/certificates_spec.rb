# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Certificates" do
  let(:registration) do
    create(:registration, :has_required_data, :expires_soon, contact_email: "contact@example.com")
      .tap(&:generate_view_certificate_token!)
  end
  let(:token) { registration.view_certificate_token }

  let(:valid_email) { registration.contact_email }
  let(:invalid_email) { "invalid@example.com" }
  let(:base_path) { "/#{registration.reg_identifier}/certificate" }
  let(:token_renewal_path) { "/#{registration.reg_identifier}/certificate_renew_token" }
  let(:token_renewal_sent_path) { "/#{registration.reg_identifier}/certificate_renewal_sent" }

  describe "POST process_email" do
    context "with valid email" do
      it "sets the valid email in session and redirects to the certificate page" do
        post process_email_path, params: { email: valid_email }
        expect(response).to redirect_to("#{base_path}?token=#{token}")
      end
    end

    context "with invalid email" do
      it "does not set the email in session and renders the confirmation page with an error" do
        post process_email_path, params: { email: invalid_email }

        expect(flash[:error]).to be_present
        expect(response).to render_template(:confirm_email)
      end
    end
  end

  describe "GET show" do
    context "with valid email in session and valid token" do
      subject(:get_certificate) { get "#{base_path}?token=#{token}" }

      before { post process_email_path, params: { email: valid_email } }

      it "renders the HTML certificate" do
        get_certificate

        expect(response.media_type).to eq("text/html")
        expect(response).to have_http_status(:ok)
      end

      it { expect { get_certificate }.not_to change { registration.reload.metaData.certificate_version } }
      it { expect { get_certificate }.not_to change { registration.metaData.certificate_version_history } }
    end

    context "with valid email in session but invalid token" do
      before { post process_email_path, params: { email: valid_email } }

      it "redirects due to invalid token" do
        get "#{base_path}?token=invalidtoken"

        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq("You do not have permission to view this page")
      end
    end

    context "with valid email in session but expired token" do
      before do
        registration.update(view_certificate_token_created_at: 7.months.ago)
        post process_email_path, params: { email: valid_email }
      end

      it "redirects due to expired token" do
        get "#{base_path}?token=#{token}"

        expect(response).to redirect_to(token_renewal_path)
      end
    end

    context "without valid email in session or token" do
      before { post process_email_path, params: { email: invalid_email } }

      it "redirects to the email confirmation page" do
        get base_path

        expect(response).to redirect_to(certificate_confirm_email_path(registration.reg_identifier))
        expect(response).to have_http_status(:found)
      end
    end

    context "without valid email in session but with valid token" do
      before { post process_email_path, params: { email: invalid_email } }

      it "redirects to the email confirmation page" do
        get "#{base_path}?token=#{token}"

        expect(response).to redirect_to(certificate_confirm_email_path(registration.reg_identifier, token: token))
        expect(response).to have_http_status(:found)
      end
    end
  end

  describe "GET pdf" do
    subject(:get_certificate) { get "#{base_path}?token=#{token}" }

    let(:base_path) { "/#{registration.reg_identifier}/pdf_certificate" }

    context "with valid email in session and valid token" do
      before { post process_email_path, params: { email: valid_email } }

      it "renders the page" do
        get_certificate

        expect(response).to have_http_status(:ok)
      end

      it { expect { get_certificate }.not_to change { registration.reload.metaData.certificate_version } }
      it { expect { get_certificate }.not_to change { registration.metaData.certificate_version_history } }
    end

    context "with valid email in session but invalid token" do
      before { post process_email_path, params: { email: valid_email } }

      it "redirects due to invalid token" do
        get "#{base_path}?token=invalidtoken"

        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq("You do not have permission to view this page")
      end
    end

    context "with valid email in session but expired token" do
      before do
        registration.update(view_certificate_token_created_at: 7.months.ago)
        post process_email_path, params: { email: valid_email }
      end

      it "redirects due to expired token" do
        get "#{base_path}?token=#{token}"

        expect(response).to redirect_to(token_renewal_path)
      end
    end

    context "without valid email in session" do
      before { post process_email_path, params: { email: invalid_email } }

      it "redirects to the email confirmation page" do
        get "#{base_path}.pdf"

        expect(response).to redirect_to(certificate_confirm_email_path(registration.reg_identifier))
        expect(response).to have_http_status(:found)
      end
    end
  end

  describe "GET confirm_email" do
    context "with a valid token" do
      it "renders the confirm email page" do
        get certificate_confirm_email_path(registration.reg_identifier, token: token)
        expect(response).to render_template(:confirm_email)
      end
    end

    context "with an invalid token" do
      before { post process_email_path, params: { email: valid_email } }

      it "redirects due to invalid token" do
        get certificate_confirm_email_path(registration.reg_identifier, token: "invalidtoken")

        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq("You do not have permission to view this page")
      end
    end

    context "with an expired token" do
      before do
        registration.update(view_certificate_token_created_at: 7.months.ago)
        registration.reload
      end

      it "redirects due to the renew token page" do
        get certificate_confirm_email_path(registration.reg_identifier, token: token)

        expect(response).to redirect_to(token_renewal_path)
      end
    end
  end

  describe "GET certificate_renew_token" do
    context "when the token has expired" do
      before { registration.update(view_certificate_token_created_at: 7.months.ago) }

      it "renders the renew token page" do
        get token_renewal_path

        expect(response).to render_template("waste_carriers_engine/certificates/renew_token")
      end
    end
  end

  describe "POST certificate_reset_token" do
    before { allow(WasteCarriersEngine::CertificateRenewalService).to receive(:run) }

    context "when the email is valid" do

      it "resets the token and redirects to the token renewal sent page" do
        post certificate_reset_token_path(reg_identifier: registration.reg_identifier, email: valid_email)

        expect(WasteCarriersEngine::CertificateRenewalService).to have_received(:run).with(registration: registration)

        expect(response).to redirect_to(token_renewal_sent_path)
        follow_redirect!
        expect(response).to render_template("waste_carriers_engine/certificates/renewal_sent")
      end
    end

    context "when the email is not valid" do
      it "does not reset the token but still directs to the token renewal sent page" do
        post certificate_reset_token_path(reg_identifier: registration.reg_identifier, email: invalid_email)
        expect(WasteCarriersEngine::CertificateRenewalService).not_to have_received(:run).with(registration: registration)

        expect(response).to redirect_to(token_renewal_sent_path)
        follow_redirect!
        expect(response).to render_template("waste_carriers_engine/certificates/renewal_sent")
      end
    end
  end

  def process_email_path
    certificate_process_email_path(registration.reg_identifier)
  end
end
