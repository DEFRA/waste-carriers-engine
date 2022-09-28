# frozen_string_literal: true

RSpec.shared_examples "Having a secure token" do
  let(:transient_registration) { build(:transient_registration) }

  it "generates a unique secure token when saved" do
    expect(transient_registration.token).to be_nil

    transient_registration.save

    expect(transient_registration.reload.token).not_to be_nil
  end
end
