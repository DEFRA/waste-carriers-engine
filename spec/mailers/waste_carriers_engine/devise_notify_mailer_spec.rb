# frozen_string_literal: true

require "rails_helper"

RSpec.describe WasteCarriersEngine::DeviseNotifyMailer do
  subject(:devise_notify_mailer) { described_class.new }

  describe "#reset_password_instructions" do
    let(:user) { create(:user, email: "test@example.com") }
    let(:token) { "example_token" }
    let(:opts) { {} }

    before do
      allow(WasteCarriersEngine::Notify::DeviseSender).to receive(:run)
    end

    it "calls the DeviseSender with reset_password_instructions template" do
      devise_notify_mailer.reset_password_instructions(user, token, opts)

      expect(WasteCarriersEngine::Notify::DeviseSender).to have_received(:run).with(
        template: :reset_password_instructions,
        record: user,
        opts: opts.merge(token: token)
      )
    end
  end

  describe "#unlock_instructions" do
    let(:user) { create(:user, email: "test@example.com") }
    let(:token) { "example_token" }
    let(:opts) { {} }

    before do
      allow(WasteCarriersEngine::Notify::DeviseSender).to receive(:run)
    end

    it "calls the DeviseSender with unlock_instructions template" do
      devise_notify_mailer.unlock_instructions(user, token, opts)

      expect(WasteCarriersEngine::Notify::DeviseSender).to have_received(:run).with(
        template: :unlock_instructions,
        record: user,
        opts: opts.merge(token: token)
      )
    end
  end
end
