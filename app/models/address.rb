class Address
  include Mongoid::Document

  embedded_in :registration
  embeds_one :location

  accepts_nested_attributes_for :location

  field :addressType, as: :address_type,                              type: String
  field :addressMode, as: :address_mode,                              type: String
  field :houseNumber, as: :house_number,                              type: String
  field :addressLine1, as: :address_line_1,                           type: String
  field :addressLine2, as: :address_line_2,                           type: String
  field :addressLine3, as: :address_line_3,                           type: String
  field :addressLine4, as: :address_line_4,                           type: String
  field :townCity, as: :town_city,                                    type: String
  field :postcode,                                                    type: String
  field :country,                                                     type: String
  field :dependentLocality, as: :dependent_locality,                  type: String
  field :administrativeArea,                                          type: String
  field :localAuthorityUpdateDate, as: :local_authority_update_date,  type: String
  field :easting,                                                     type: Integer
  field :northing,                                                    type: Integer
  field :firstOrOnlyEasting, as: :first_or_only_easting,              type: Integer
  field :firstOrOnlyNorthing, as: :first_or_only_northing,            type: Integer

  def self.create_from_manual_entry(params, business_type)
    address = Address.new

    address[:address_mode] = if business_type == "overseas"
                               "manual-foreign"
                             else
                               "manual-uk"
                             end

    address[:house_number] = params[:house_number]
    address[:address_line_1] = params[:address_line_1]
    address[:address_line_2] = params[:address_line_2]
    address[:town_city] = params[:town_city]
    address[:postcode] = params[:postcode]
    address[:country] = params[:country]

    address
  end
end
