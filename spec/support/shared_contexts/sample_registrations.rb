# frozen_string_literal: true

RSpec.shared_context "with a sample registration with defaults" do |factory|
  let(:company_name) { Faker::Lorem.sentence(word_count: 3) }
  let(:registered_company_name) { nil }
  let(:tier) { "UPPER" }
  let(:business_type) { "limitedCompany" }
  let(:registration_type) { "carrier_broker_dealer" }
  let(:route) { "DIGITAL" }

  let(:person_a) { build(:key_person, :main, first_name: Faker::Name.first_name, last_name: Faker::Name.last_name) }
  let(:person_b) { build(:key_person, :main, first_name: Faker::Name.first_name, last_name: Faker::Name.last_name) }
  let(:key_people) { [person_a, person_b] }

  let(:resource) do
    build(factory, company_name: company_name,
                   registration_type: registration_type,
                   registered_company_name: registered_company_name,
                   business_type: business_type,
                   tier: tier,
                   key_people: key_people,
                   metaData: { route: route })
  end
end
