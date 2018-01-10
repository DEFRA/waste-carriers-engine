require "rails_helper"

RSpec.describe "registrations/index", type: :view do
  before(:each) do
    assign(:registrations, [
             create(
               :registration,
               :has_required_data,
               reg_identifier: "Reg Identifier 1",
               company_name: "Company Name Index"
             ),
             create(
               :registration,
               :has_required_data,
               reg_identifier: "Reg Identifier 2",
               company_name: "Company Name Index"
             )
           ])
  end

  it "renders a list of registrations" do
    render
    assert_select "tr>td", text: "Reg Identifier 1".to_s, count: 1
    assert_select "tr>td", text: "Reg Identifier 2".to_s, count: 1
    assert_select "tr>td", text: "Company Name Index".to_s, count: 2
  end
end
