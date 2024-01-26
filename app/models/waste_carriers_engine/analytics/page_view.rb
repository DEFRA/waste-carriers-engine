# frozen_string_literal: true

module WasteCarriersEngine
  module Analytics
    class PageView
      include Mongoid::Document

      store_in collection: "analytics_page_views"

      embedded_in :user_journey

      # TODO: Needed temporarily to support the embed_page_views_in_user_journey migration task;
      # TODO: Remove this after the migration task has been run in production.
      field :user_journey_id, type: BSON::ObjectId

      field :page, type: String
      field :time, type: DateTime
      field :route, type: String
    end
  end
end
