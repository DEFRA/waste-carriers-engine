# frozen_string_literal: true

RSpec.shared_examples "can create a communication record" do |notification_type|
  let(:comms_label) { described_class::COMMS_LABEL }
  let(:time_sent) { Time.now.utc }
  let(:recipient) do
    if notification_type == "letter"
      "Jane Doe, 42, Foo Gardens, Baz City, BS1 5AH"
    elsif notification_type == "email"
      registration.contact_email
    end
  end
  let(:expected_communication_record_attrs) do
    {
      notify_template_id: template_id,
      notification_type: notification_type,
      comms_label: comms_label,
      sent_at: time_sent,
      sent_to: recipient
    }
  end

  it "creates a communication record with the expected attributes" do
    Timecop.freeze(time_sent) do
      response = nil
      expect { response = run_service }.to change { registration.communication_records.count }.by(1)

      expect(registration.communication_records.last).to have_attributes(
        expected_communication_record_attrs.merge(
          notification_id: response.id,
          subject: response.content["subject"],
          content: response.content["body"],
          delivery_status: "sent"
        )
      )
    end
  end

  context "when the Notify request fails" do
    let(:notify_method) do
      { "letter" => :send_letter, "sms" => :send_sms }.fetch(notification_type, :send_email)
    end
    let(:notify_error) do
      Notifications::Client::BadRequestError.new(
        instance_double(
          Net::HTTPClientError,
          code: 400,
          body: { "errors" => [{ "error" => "BadRequestError", "message" => "Can't send to this recipient" }] }.to_json
        )
      )
    end

    let(:failing_client) { instance_double(Notifications::Client) }

    before do
      allow(Notifications::Client).to receive(:new).and_return(failing_client)
      allow(failing_client).to receive(notify_method).and_raise(notify_error)
    end

    it "creates a communication record with the error message as the delivery status" do
      expect { run_service }.to raise_error(Notifications::Client::BadRequestError)

      record = registration.communication_records.last
      expect(record[:delivery_status]).to eq("BadRequestError: Can't send to this recipient")
      expect(record[:subject]).to be_nil
      expect(record[:content]).to be_nil
      expect(record[:notification_id]).to be_nil
      expect(record[:notify_template_id]).to eq(template_id)
    end
  end
end
