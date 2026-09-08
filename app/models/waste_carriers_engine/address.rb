# frozen_string_literal: true

module WasteCarriersEngine
  class Address
    include Mongoid::Document

    embedded_in :registration,      class_name: "WasteCarriersEngine::Registration"
    embedded_in :past_registration, class_name: "WasteCarriersEngine::PastRegistration"
    embeds_one :location,           class_name: "WasteCarriersEngine::Location"

    accepts_nested_attributes_for :location

    field :uprn,                                                        type: Integer
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
    field :dependentThoroughfare, as: :dependent_thoroughfare,          type: String
    field :administrativeArea, as: :administrative_area,                type: String
    field :localAuthorityUpdateDate, as: :local_authority_update_date,  type: String
    field :royalMailUpdateDate, as: :royal_mail_update_date,            type: String
    field :easting,                                                     type: Integer
    field :northing,                                                    type: Integer
    field :area,                                                        type: String
    field :firstOrOnlyEasting, as: :first_or_only_easting,              type: Integer
    field :firstOrOnlyNorthing, as: :first_or_only_northing,            type: Integer
    field :firstName, as: :first_name,                                  type: String
    field :lastName, as: :last_name,                                    type: String

    validates :address_type, presence: true

    def self.create_from_manual_entry(params, overseas)
      address = Address.new

      address[:address_mode] = if overseas
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

    def self.create_from_os_places_data(data)
      Address.new.update_from_os_places_data(data)
    end

    def update_from_os_places_data(data)
      self[:uprn] = data["uprn"]
      self[:address_mode] = "address-results"
      self[:dependent_locality] = data["locality"]
      self[:administrative_area] = data["city"]
      self[:town_city] = data["city"]
      self[:postcode] = data["postcode"]
      self[:country] = data["country"]
      self[:local_authority_update_date] = data["last_update_date"]
      self[:easting] = data["x"]&.to_i
      self[:northing] = data["y"]&.to_i

      assign_house_number_and_address_lines(data)

      self
    end

    def assign_house_number_and_address_lines(os_data)
      lines = leading_lines_before_street(os_data)
      lines += [os_data["street_address"], os_data["locality"]]
      lines = lines.reject(&:blank?)

      address_attributes = %i[house_number
                              address_line_1
                              address_line_2
                              address_line_3
                              address_line_4]

      # Fold surplus leading parts into house_number so no line is lost
      overflow = lines.size - address_attributes.size
      lines = [lines.shift(overflow + 1).join(", ")] + lines if overflow.positive?

      # Assign lines one at a time until we run out of lines to assign
      write_attribute(address_attributes.shift, lines.shift) until lines.empty?
    end

    private

    # The lines that come before the street (organisation, sub-building, premises).
    # Prefer parsing them from the full "address" string, as components like a flat
    # or sub-building name have no structured field of their own and would be lost.
    def leading_lines_before_street(os_data)
      structured = [os_data["organisation"], os_data["premises"]].reject(&:blank?)
      prefix = address_prefix_before_street(os_data)
      return structured if prefix.blank?
      return [prefix] if structured.empty?

      parts = prefix.split(/,\s*/)

      # Never drop a structured value the prefix did not include
      structured.each do |value|
        parts << value if parts.none? { |part| part.casecmp?(value) }
      end

      parts
    end

    def address_prefix_before_street(os_data)
      address = os_data["address"]
      street_address = os_data["street_address"]

      return nil if address.blank? || street_address.blank?

      # Find where street_address starts in the full address (case-insensitive)
      street_index = address.upcase.index(street_address.upcase)
      return nil if street_index.nil? || street_index.zero?

      # Extract everything before street_address and clean trailing comma/spaces
      address[0...street_index].sub(/,\s*\z/, "").strip.presence
    end

    def manually_entered?
      %w[manual-foreign manual-uk].include?(address_mode)
    end
  end
end
