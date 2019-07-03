# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "Pages", type: :request do
    %i[cookies privacy].each do |page|
      it "displays the correct page" do
        get page_path(page)

        expect(response).to have_http_status(200)
        expect(response).to render_template(page)
      end
    end
  end
end
