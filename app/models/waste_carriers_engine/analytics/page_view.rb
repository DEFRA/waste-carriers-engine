# frozen_string_literal: true

module WasteCarriersEngine
  module Analytics
    class PageView
      include Mongoid::Document

      store_in collection: "analytics_page_views"

      belongs_to :user_journey

      field :page, type: String
      field :time, type: DateTime
      field :route, type: String
    end
  end
end
