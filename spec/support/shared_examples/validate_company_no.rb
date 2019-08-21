# frozen_string_literal: true

# Tests for fields using the CompaniesHouseNumberValidator
RSpec.shared_examples "validate company_no" do |form_factory|
  before do
    allow_any_instance_of(DefraRuby::Validators::CompaniesHouseService).to receive(:status).and_return(:active)
  end

  it "validates the company_no using the CompaniesHouseNumberValidator class" do
    validators = build(form_factory, :has_required_data)._validators
    expect(validators.keys).to include(:company_no)
    expect(validators[:company_no].first.class)
      .to eq(DefraRuby::Validators::CompaniesHouseNumberValidator)
  end
end
