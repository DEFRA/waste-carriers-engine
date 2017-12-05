require "rails_helper"

RSpec.describe "registrations/edit", type: :view do
  before(:each) do
    @registration = assign(:registration, create(
                                            :registration,
                                            :has_required_data,
                                            reg_identifier: "Reg Identifier",
                                            company_name: "Company Name Edit"
    ))
  end

  it "renders the edit registration form" do
    render

    assert_select "form[action=?][method=?]", registration_path(@registration), "post" do

      assert_select "input#registration_reg_identifier[name=?]", "registration[reg_identifier]"

      assert_select "input#registration_company_name[name=?]", "registration[company_name]"
    end
  end
end
