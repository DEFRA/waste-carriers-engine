module WasteCarriersEngine
  # Define the attributes a registration or a renewal has
  module CanHaveRegistrationAttributes
    extend ActiveSupport::Concern
    include Mongoid::Document

    included do
      embeds_many :addresses,               class_name: "WasteCarriersEngine::Address"
      embeds_one :conviction_search_result, class_name: "WasteCarriersEngine::ConvictionSearchResult"
      embeds_many :conviction_sign_offs,    class_name: "WasteCarriersEngine::ConvictionSignOff"
      embeds_one :finance_details,          class_name: "WasteCarriersEngine::FinanceDetails", store_as: "financeDetails"
      embeds_many :key_people,              class_name: "WasteCarriersEngine::KeyPerson"
      embeds_one :metaData,                 class_name: "WasteCarriersEngine::MetaData"

      accepts_nested_attributes_for :addresses,
                                    :conviction_search_result,
                                    :conviction_sign_offs,
                                    :finance_details,
                                    :key_people,
                                    :metaData

      field :accessCode, as: :address_code,                                 type: String
      field :accountEmail, as: :account_email,                              type: String
      field :businessType, as: :business_type,                              type: String
      field :companyName, as: :company_name,                                type: String
      field :company_no,                                                    type: String # May include letters, despite name
      field :constructionWaste, as: :construction_waste,                    type: String # 'yes' or 'no' - should refactor to boolean
      field :contactEmail, as: :contact_email,                              type: String
      field :copy_cards,                                                    type: Integer
      field :declaration,                                                   type: Integer
      field :declaredConvictions, as: :declared_convictions,                type: String # 'yes' or 'no' - should refactor to boolean
      field :expires_on,                                                    type: DateTime
      field :firstName, as: :first_name,                                    type: String
      field :isMainService, as: :is_main_service,                           type: String # 'yes' or 'no' - should refactor to boolean
      field :lastName, as: :last_name,                                      type: String
      field :location,                                                      type: String
      field :onlyAMF, as: :only_amf,                                        type: String # 'yes' or 'no' - should refactor to boolean
      field :originalDateExpiry, as: :original_date_expiry,                 type: DateTime
      field :originalRegistrationNumber, as: :original_registration_number, type: String
      field :otherBusinesses, as: :other_businesses,                        type: String # 'yes' or 'no' - should refactor to boolean
      field :phoneNumber, as: :phone_number,                                type: String
      field :regIdentifier, as: :reg_identifier,                            type: String
      field :reg_uuid,                                                      type: String # Used by waste-carriers-frontend
      field :registrationType, as: :registration_type,                      type: String
      field :tier,                                                          type: String
      field :uuid,                                                          type: String

      def contact_address
        return nil unless addresses.present?
        addresses.where(address_type: "POSTAL").first
      end

      def registered_address
        return nil unless addresses.present?
        addresses.where(address_type: "REGISTERED").first
      end

      def overseas?
        location == "overseas"
      end

      def main_people
        return [] unless key_people.present?
        key_people.where(person_type: "KEY")
      end

      def relevant_people
        return [] unless key_people.present?
        key_people.where(person_type: "RELEVANT")
      end

      def conviction_check_required?
        return false unless conviction_sign_offs.present? && conviction_sign_offs.length.positive?
        conviction_sign_offs.first.confirmed == "no"
      end

      def conviction_check_approved?
        return false unless conviction_sign_offs.present? && conviction_sign_offs.length.positive?
        conviction_sign_offs.first.confirmed == "yes"
      end

      def business_has_matching_or_unknown_conviction?
        return true unless conviction_search_result.present?
        return false if conviction_search_result.match_result == "NO"
        true
      end

      def key_person_has_matching_or_unknown_conviction?
        return true unless key_people.present?
        all_requirements = key_people.map(&:conviction_check_required?)
        all_requirements.include?(true)
      end

      def update_last_modified
        return unless metaData.present?
        metaData.last_modified = Time.current
      end
    end
  end
end
