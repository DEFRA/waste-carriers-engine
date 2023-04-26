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

    scope :missing_area, -> { any_of({ area: nil }, { area: "" }) }
    scope :with_postcode, -> { where(:postcode.ne => nil) }

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
      address = Address.new

      address[:uprn] = data["uprn"]
      address[:address_mode] = "address-results"
      address[:dependent_locality] = data["dependentLocality"]
      address[:administrative_area] = data["administrativeArea"]
      address[:town_city] = data["town"]
      address[:postcode] = data["postcode"]
      address[:country] = data["country"]
      address[:local_authority_update_date] = data["localAuthorityUpdateDate"]
      address[:easting] = data["easting"]
      address[:northing] = data["northing"]

      address.assign_house_number_and_address_lines(data)

      address
    end

    def assign_house_number_and_address_lines(os_data)
      data = os_data.clone.slice("departmentName", "organisationName", "postOfficeBoxNumber",
                                 "subBuildingName", "buildingName", "buildingNumber",
                                 "dependentThroughfare", "thoroughfareName", "dependentLocality")
                    .delete_if { |_k, v| v.nil? || v.empty? }

      # Avoid exceeding the number of available lines by merging some values if necessary.
      combined_if_length_exceeds(5, data, "departmentName", "organisationName")
      combined_if_length_exceeds(5, data, "subBuildingName", "buildingName")
      combined_if_length_exceeds(5, data, "buildingNumber", "dependentThroughfare")

      lines = data.values.reject(&:blank?)

      address_attributes = %i[house_number
                              address_line_1
                              address_line_2
                              address_line_3
                              address_line_4]

      # Assign lines one at a time until we run out of lines to assign
      write_attribute(address_attributes.shift, lines.shift) until lines.empty?
    end

    def combined_if_length_exceeds(max_lines, data, field1, field2)
      return if data.keys.length <= max_lines

      return if !data[field1].present? || !data[field2].present?

      data[field2] = data.values_at(field1, field2).reject(&:blank?).join(", ")
      data.delete(field1)
    end

    def manually_entered?
      address_mode == "manual-foreign" || address_mode == "manual-uk"
    end
  end
end
