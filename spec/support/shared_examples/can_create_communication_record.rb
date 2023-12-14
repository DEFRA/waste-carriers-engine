# frozen_string_literal: true

RSpec.shared_examples "can create a communication record" do |notification_type|
  let(:comms_label) { described_class::COMMS_LABEL }
  let(:time_sent) { Time.now.utc }
  let(:expected_communication_record_attrs) do
    {
      notify_template_id: template_id,
      notification_type: notification_type,
      comms_label: comms_label,
      sent_at: time_sent
    }
  end

  it "will create a communication record with the expected attributes" do
    Timecop.freeze(time_sent) do
      expect { run_service }.to change { registration.communication_records.count }.by(1)
      expect(registration.communication_records.last[:notify_template_id]).to eq(expected_communication_record_attrs[:notify_template_id])
      expect(registration.communication_records.last[:notification_type]).to eq(expected_communication_record_attrs[:notification_type])
      expect(registration.communication_records.last[:comms_label]).to eq(expected_communication_record_attrs[:comms_label])
      expect(registration.communication_records.last[:sent_at]).to eq(expected_communication_record_attrs[:sent_at])
    end
  end
end
