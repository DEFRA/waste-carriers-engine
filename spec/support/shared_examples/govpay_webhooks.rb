# frozen_string_literal: true

RSpec.shared_examples "logs an error" do
  before do
    allow(Airbrake).to receive(:notify)
    allow(Rails.logger).to receive(:error)
  end

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
  before { allow(Airbrake).to receive(:notify) }

  it "does not notify Airbrake" do
    run_service

    expect(Airbrake).not_to have_received(:notify)
  end
end

RSpec.shared_examples "a valid transition" do |old_status, new_status|
  let(:prior_payment_status) { old_status }

  before do
    assign_webhook_status(new_status)

    allow(Airbrake).to receive(:notify)
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
  valid_statuses.each do |new_status|
    it_behaves_like "a valid transition", old_status, new_status
  end

  invalid_statuses.each do |new_status|
    it_behaves_like "an invalid transition", old_status, new_status
  end
end

RSpec.shared_examples "no valid transitions" do |old_status|
  it_behaves_like "valid and invalid transitions", old_status, %w[], %w[created started submitted success failed cancelled error] - [old_status]
end

def assign_webhook_status(status)
  webhook_body["resource"]["state"]["status"] = status
end
