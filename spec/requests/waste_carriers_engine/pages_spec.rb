# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "Pages" do
    %i[invalid os-terms permission privacy unrenewable version].each do |page|
      it "displays the correct page" do
        get page_path(page)

        expect(response).to have_http_status(:ok)
        expect(response).to render_template(page)
      end
    end
  end
end
