module WasteCarriersEngine
  class Location
    include Mongoid::Document

    embedded_in :address

    field :lat, type: BigDecimal
    field :lon, type: BigDecimal
  end
end
