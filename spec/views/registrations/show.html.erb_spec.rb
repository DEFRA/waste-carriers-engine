require "rails_helper"

RSpec.describe "registrations/show", type: :view do
  before(:each) do
    @registration = assign(:registration, create(
                                            :registration,
                                            :has_required_data,
                                            reg_identifier: "Reg Identifier Show",
                                            company_name: "Company Name Show"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Reg Identifier Show/)
    expect(rendered).to match(/Company Name Show/)
  end
end
