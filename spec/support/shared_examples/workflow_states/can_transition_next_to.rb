# frozen_string_literal: true

RSpec.shared_examples "can transition next to" do |next_state:|
  it "can transition next to #{next_state}" do
    subject.next

    expect(subject.workflow_state).to eq(next_state)
  end
end
