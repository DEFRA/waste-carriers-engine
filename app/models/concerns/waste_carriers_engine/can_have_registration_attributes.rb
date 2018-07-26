module WasteCarriersEngine
  # Define the attributes a registration or a renewal has
  module CanHaveRegistrationAttributes
    extend ActiveSupport::Concern
    include Mongoid::Document

    included do
      embeds_one :metaData,                 class_name: "WasteCarriersEngine::MetaData"
      embeds_many :addresses,               class_name: "WasteCarriersEngine::Address"
      embeds_many :key_people,              class_name: "WasteCarriersEngine::KeyPerson"
      embeds_one :finance_details,          class_name: "WasteCarriersEngine::FinanceDetails", store_as: "financeDetails"
      embeds_one :conviction_search_result, class_name: "WasteCarriersEngine::ConvictionSearchResult"
      embeds_many :conviction_sign_offs,    class_name: "WasteCarriersEngine::ConvictionSignOff"

      accepts_nested_attributes_for :metaData,
                                    :addresses,
                                    :key_people,
                                    :finance_details,
                                    :conviction_search_result,
                                    :conviction_sign_offs

      field :uuid,                                                          type: String
      field :reg_uuid,                                                      type: String # Used by waste-carriers-frontend
      field :originalRegistrationNumber, as: :original_registration_number, type: String # Used by waste-carriers-frontend
      field :tier,                                                          type: String
      field :registrationType, as: :registration_type,                      type: String
      field :location,                                                      type: String
      field :businessType, as: :business_type,                              type: String
      field :otherBusinesses, as: :other_businesses,                        type: String # 'yes' or 'no' - should refactor to boolean
      field :isMainService, as: :is_main_service,                           type: String # 'yes' or 'no' - should refactor to boolean
      field :onlyAMF, as: :only_amf,                                        type: String # 'yes' or 'no' - should refactor to boolean
      field :constructionWaste, as: :construction_waste,                    type: String # 'yes' or 'no' - should refactor to boolean
      field :companyName, as: :company_name,                                type: String
      field :companyNo, as: :company_no,                                    type: String # May include letters, despite name
      field :firstName, as: :first_name,                                    type: String
      field :lastName, as: :last_name,                                      type: String
      field :phoneNumber, as: :phone_number,                                type: String
      field :contactEmail, as: :contact_email,                              type: String
      field :accountEmail, as: :account_email,                              type: String
      field :declaredConvictions, as: :declared_convictions,                type: String # 'yes' or 'no' - should refactor to boolean
      field :declaration,                                                   type: Integer # Unsure of type
      field :regIdentifier, as: :reg_identifier,                            type: String
      field :expires_on,                                                    type: DateTime
      field :copy_cards,                                                    type: Integer

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
        key_people.where(person_type: "key")
      end

      def relevant_people
        return [] unless key_people.present?
        key_people.where(person_type: "relevant")
      end

      def conviction_check_required?
        return true if declared_convictions == "yes"
        business_has_matching_or_unknown_conviction? || key_person_has_matching_or_unknown_conviction?
      end

      def business_has_matching_or_unknown_conviction?
        return true unless conviction_search_result.present?
        return false if conviction_search_result.match_result == "NO"
        true
      end

      def key_person_has_matching_or_unknown_conviction?
        return true unless key_people.present?

        conviction_search_results = key_people.map(&:conviction_search_result)
        match_results = conviction_search_results.map(&:match_result)

        match_results.include?("YES") || match_results.include?("UNKNOWN")
      end

      def update_last_modified
        return unless metaData.present?
        metaData.last_modified = Time.current
      end
    end
  end
end
