# frozen_string_literal: true

RSpec.shared_examples "can transition back to" do |previous_state:|
  it "can transition back to #{previous_state}" do
    subject.back

    expect(subject.workflow_state).to eq(previous_state)
  end
end
