# frozen_string_literal: true

module WasteCarriersEngine
  # Define the attributes a registration or a renewal has
  # rubocop:disable Metrics/ModuleLength
  module CanHaveRegistrationAttributes
    extend ActiveSupport::Concern
    include Mongoid::Document
    include CanReferenceSingleDocumentInCollection

    # Rubocop sees a module as a block, and as such is not very forgiving in how
    # many lines it allows. In the case of this concern we have to list out all
    # the attributes on a registration so cannot help it being overly long.
    # rubocop:disable Metrics/BlockLength
    included do
      # For this section only we feel it makes it more readble if certain
      # attributes are aligned. The problem is this doesn't allow us much room
      # for comments in some places, and putting them on the line above breaks
      # the formatting we have in place.
      # rubocop:disable Metrics/LineLength
      embeds_many :addresses, class_name: "WasteCarriersEngine::Address"

      # This is our own custom association. See CanReferenceSingleDocumentInCollection for details
      reference_one :contact_address, collection: :addresses, find_by: { address_type: "POSTAL" }
      reference_one :company_address, collection: :addresses, find_by: { address_type: "REGISTERED" }
      # TODO: Remove this and always use `company_address` rather than `registrered_address`
      reference_one :registered_address, collection: :addresses, find_by: { address_type: "REGISTERED" }

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
      field :registrationType, as: :registration_type,                      type: String
      field :reg_uuid,                                                      type: String # Used by waste-carriers-frontend
      field :tier,                                                          type: String
      field :uuid,                                                          type: String
      # rubocop:enable Metrics/LineLength

      # Deprecated attributes
      # These are attributes which were in use during earlier stages of the
      # project, but are no longer used. However, in some cases older
      # registrations still use these fields, so we need to allow for them
      # to avoid causing database errors.
      field :copy_card_fee,                                    type: String
      field :copy_cards,                                       type: String
      field :individualsType, as: :individuals_type,           type: String
      field :otherTitle, as: :other_title,                     type: String
      field :position,                                         type: String
      field :publicBodyType, as: :public_body_type,            type: String
      field :publicBodyTypeOther, as: :public_body_type_other, type: String
      field :registration_fee,                                 type: String
      field :renewalRequested, as: :renewal_requested,         type: String
      field :title,                                            type: String
      field :total_fee,                                        type: String

      scope :search_term, lambda { |term|
        escaped_term = Regexp.escape(term) if term.present?

        any_of({ reg_identifier: /\A#{escaped_term}\z/i },
               { company_name: /#{escaped_term}/i },
               { last_name: /#{escaped_term}/i },
               "addresses.postcode": /#{escaped_term}/i)
      }

      def charity?
        business_type == "charity"
      end

      def overseas?
        location == "overseas" || business_type == "overseas"
      end

      def upper_tier?
        tier == "UPPER"
      end

      def lower_tier?
        tier == "LOWER"
      end

      def ad_contact_email?
        contact_email.blank? || contact_email == WasteCarriersEngine.configuration.assisted_digital_email
      end

      # Some business types should not have a company_no
      def company_no_required?
        return false if overseas?

        %w[limitedCompany limitedLiabilityPartnership].include?(business_type)
      end

      def rejected_conviction_checks?
        return false unless conviction_sign_offs&.any?

        conviction_sign_offs.last.rejected?
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

      def declaration_confirmed?
        declaration == 1
      end

      def unpaid_balance?
        return true if finance_details.presence&.balance&.positive?

        false
      end

      def amount_paid
        (finance_details.presence&.payments || []).inject(0) do |tot, payment|
          tot + payment.amount
        end
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
  # rubocop:enable Metrics/ModuleLength
end
