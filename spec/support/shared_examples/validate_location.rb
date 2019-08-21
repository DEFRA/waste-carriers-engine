# frozen_string_literal: true

# Tests for fields using the LocationValidator
RSpec.shared_examples "validate location" do |form_factory|
  it "validates the location using the LocationValidator class" do
    validators = build(form_factory, :has_required_data)._validators
    expect(validators.keys).to include(:location)
    expect(validators[:location].first.class)
      .to eq(DefraRuby::Validators::LocationValidator)
  end
end
