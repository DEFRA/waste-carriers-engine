# frozen_string_literal: true

RSpec.shared_context "with logger stubs" do
  before do
    allow(Airbrake).to receive(:notify)
    allow(Rails.logger).to receive(:info)
    allow(Rails.logger).to receive(:warn)
    allow(Rails.logger).to receive(:error)
  end
end

RSpec.shared_examples "logs an error" do
  # include_context "logger stubs"

  it "notifies Airbrake" do
    run_service

    expect(Airbrake).to have_received(:notify)
  rescue StandardError
    # expected exception
  end

  it "writes an error to the Rails log" do
    run_service

    expect(Rails.logger).to have_received(:error)
  rescue StandardError
    # expected exception
  end
end

RSpec.shared_examples "does not log an error" do
  # include_context "logger stubs"

  it "does not notify Airbrake" do
    run_service

    expect(Airbrake).not_to have_received(:notify)
  end

  it "does not write an error to the Rails log" do
    run_service

    expect(Rails.logger).not_to have_received(:error)
  end
end

RSpec.shared_examples "a valid transition" do |old_status, new_status|
  # include_context "logger stubs"

  let(:prior_payment_status) { old_status }

  before do
    allow(Rails.logger).to receive(:info)
    allow(Airbrake).to receive(:notify)
    assign_webhook_status(new_status)
  end

  it "updates the status from #{old_status} to #{new_status}" do
    expect { run_service }.to change { wcr_payment.reload.govpay_payment_status }.to(new_status)
  end

  it "does not log an error" do
    run_service
    expect(Airbrake).not_to have_received(:notify)
  end

  it "writes an info message to the Rails log" do
    run_service

    expect(Rails.logger).to have_received(:info)
  end
end

RSpec.shared_examples "an invalid transition" do |old_status, new_status|
  # include_context "logger stubs"

  let(:prior_payment_status) { old_status }

  before { assign_webhook_status(new_status) }

  it "does not update the status from #{old_status} to #{new_status}" do
    expect { run_service }.not_to(change { wcr_payment.reload.govpay_payment_status })
  rescue DefraRubyGovpay::WebhookBaseService::InvalidStatusTransition
    # expected exception
  end

  it "logs an error when attempting to update status from #{old_status} to #{new_status}" do
    run_service

    expect(Airbrake).to have_received(:notify)
  rescue DefraRubyGovpay::WebhookBaseService::InvalidStatusTransition
    # expected exception
  end
end

RSpec.shared_examples "valid and invalid transitions" do |old_status, valid_statuses, invalid_statuses|
  # include_context "logger stubs"

  valid_statuses.each do |new_status|
    it_behaves_like "a valid transition", old_status, new_status
  end

  invalid_statuses.each do |new_status|
    it_behaves_like "an invalid transition", old_status, new_status
  end
end

RSpec.shared_examples "no valid transitions" do |old_status|
  # include_context "logger stubs"

  it_behaves_like "valid and invalid transitions", old_status, %w[], %w[created started submitted success failed cancelled error] - [old_status]
end
