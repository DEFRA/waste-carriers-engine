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
      # Extract house number from address field only when org/premises are blank
      extracted_house_number = extract_house_number_from_address(os_data)

      data = os_data.clone.slice("organisation", "premises", "street_address", "locality")
                    .delete_if { |_k, v| v.nil? || v.empty? }

      lines = data.values.reject(&:blank?)

      # Prepend extracted house number if we found one
      lines.unshift(extracted_house_number) if extracted_house_number.present?

      address_attributes = %i[house_number
                              address_line_1
                              address_line_2
                              address_line_3
                              address_line_4]

      # Assign lines one at a time until we run out of lines to assign
      write_attribute(address_attributes.shift, lines.shift) until lines.empty?
    end

    private

    def extract_house_number_from_address(os_data)
      # Only extract when organisation AND premises are both blank
      # Otherwise, those fields already contain the relevant info
      return nil if os_data["organisation"].present? || os_data["premises"].present?

      address = os_data["address"]
      street_address = os_data["street_address"]

      return nil if address.blank? || street_address.blank?

      # Find where street_address starts in the full address (case-insensitive)
      street_index = address.upcase.index(street_address.upcase)
      return nil if street_index.nil? || street_index.zero?

      # Extract everything before street_address and clean trailing comma/spaces
      prefix = address[0...street_index]
      prefix.sub(/,\s*\z/, "").strip.presence
    end

    def manually_entered?
      %w[manual-foreign manual-uk].include?(address_mode)
    end
  end
end
