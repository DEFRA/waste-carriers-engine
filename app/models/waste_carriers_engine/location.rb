class Location
  include Mongoid::Document

  embedded_in :address

  field :lat, type: BigDecimal # TODO: Confirm
  field :lon, type: BigDecimal # TODO: Confirm
end
