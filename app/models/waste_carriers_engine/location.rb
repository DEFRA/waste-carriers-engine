# frozen_string_literal: true

module WasteCarriersEngine
  class Location
    include Mongoid::Document

    embedded_in :address, class_name: "WasteCarriersEngine::Address"

    field :lat, type: BigDecimal
    field :lon, type: BigDecimal
  end
end
