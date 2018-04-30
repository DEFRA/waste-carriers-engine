# Define the attributes a registration or a renewal has
module CanHaveRegistrationAttributes
  extend ActiveSupport::Concern
  include Mongoid::Document

  included do
    embeds_one :metaData
    embeds_many :addresses
    embeds_many :keyPeople
    embeds_one :financeDetails
    embeds_one :convictionSearchResult
    embeds_many :conviction_sign_offs

    accepts_nested_attributes_for :metaData,
                                  :addresses,
                                  :keyPeople,
                                  :financeDetails,
                                  :convictionSearchResult,
                                  :conviction_sign_offs

    field :uuid,                                            type: String
    field :tier,                                            type: String
    field :registrationType, as: :registration_type,        type: String
    field :location,                                        type: String
    field :businessType, as: :business_type,                type: String
    field :otherBusinesses, as: :other_businesses,          type: Boolean
    field :isMainService, as: :is_main_service,             type: Boolean
    field :onlyAMF, as: :only_amf,                          type: Boolean
    field :constructionWaste, as: :construction_waste,      type: Boolean
    field :companyName, as: :company_name,                  type: String
    field :companyNo, as: :company_no,                      type: String # Despite its name, this can include letters
    field :firstName, as: :first_name,                      type: String
    field :lastName, as: :last_name,                        type: String
    field :phoneNumber, as: :phone_number,                  type: String
    field :contactEmail, as: :contact_email,                type: String
    field :accountEmail, as: :account_email,                type: String
    field :declaredConvictions, as: :declared_convictions,  type: Boolean
    field :declaration,                                     type: Integer # Unsure of type
    field :regIdentifier, as: :reg_identifier,              type: String
    field :expires_on,                                      type: DateTime

    def contact_address
      return nil unless addresses.present?
      addresses.where(address_type: "CONTACT").first
    end

    def registered_address
      return nil unless addresses.present?
      addresses.where(address_type: "REGISTERED").first
    end

    def overseas?
      location == "overseas"
    end

    def main_people
      return [] unless keyPeople.present?
      keyPeople.where(person_type: "key")
    end

    def relevant_people
      return [] unless keyPeople.present?
      keyPeople.where(person_type: "relevant")
    end

    def conviction_check_required?
      declared_convictions == true
    end
  end
end
