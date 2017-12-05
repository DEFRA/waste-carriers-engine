require "rails_helper"

RSpec.describe "registrations/new", type: :view do
  before(:each) do
    assign(:registration, Registration.new(
                            reg_identifier: "Reg Identifier",
                            company_name: "Company Name New"
    ))
  end

  it "renders new registration form" do
    render

    assert_select "form[action=?][method=?]", registrations_path, "post" do

      assert_select "input#registration_reg_identifier[name=?]", "registration[reg_identifier]"

      assert_select "input#registration_company_name[name=?]", "registration[company_name]"
    end
  end
end
