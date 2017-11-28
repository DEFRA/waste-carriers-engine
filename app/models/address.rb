class Address
  include Mongoid::Document

  embedded_in :registration
  embeds_one :location

  accepts_nested_attributes_for :location

  field :addressType,               type: String
  field :addressMode,               type: String
  field :houseNumber,               type: String # Instead of integer - could be 1A
  field :addressLine1,              type: String
  field :addressLine2,              type: String
  field :addressLine3,              type: String
  field :addressLine4,              type: String
  field :townCity,                  type: String
  field :postcode,                  type: String
  field :country,                   type: String
  field :dependentLocality,         type: String
  field :administrativeArea,        type: String
  field :localAuthorityUpdateDate,  type: String
  field :easting,                   type: Integer
  field :northing,                  type: Integer
  field :firstOrOnlyEasting,        type: Integer
  field :firstOrOnlyNorthing,       type: Integer
end
