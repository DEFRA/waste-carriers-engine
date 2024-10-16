# frozen_string_literal: true

module WasteCarriersEngine
  # Define the attributes a registration or a renewal has

  # rubocop:disable Metrics/ModuleLength
  module CanHaveRegistrationAttributes
    extend ActiveSupport::Concern
    include Mongoid::Document
    include CanHaveTier

    # Rubocop sees a module as a block, and as such is not very forgiving in how
    # many lines it allows. In the case of this concern we have to list out all
    # the attributes on a registration so cannot help it being overly long.
    # rubocop:disable Metrics/BlockLength
    included do
      # For this section only we feel it makes it more readble if certain
      # attributes are aligned. The problem is this doesn't allow us much room
      # for comments in some places, and putting them on the line above breaks
      # the formatting we have in place.

      # rubocop:disable Layout/LineLength
      embeds_many :addresses, class_name: "WasteCarriersEngine::Address"

      # Define helper accessor and assignment methods for each address type
      %w[contact registered].each do |address_type|

        define_method(:"#{address_type}_address") do
          addresses.where(address_type: address_type.upcase).first
        end

        define_method(:"#{address_type}_address=") do |address|
          unless address.blank? || address.address_type == address_type.upcase
            raise ArgumentError, "Attempted to set #{address_type} address with address of type #{address.address_type}"
          end

          # clear any existing address of this type
          addresses.where(address_type: address_type.upcase).first&.destroy!

          addresses << address
        end
      end

      embeds_one :conviction_search_result, class_name: "WasteCarriersEngine::ConvictionSearchResult"
      embeds_many :conviction_sign_offs,    class_name: "WasteCarriersEngine::ConvictionSignOff"
      embeds_one :finance_details,          class_name: "WasteCarriersEngine::FinanceDetails",
                                            store_as: "financeDetails"
      embeds_many :key_people,              class_name: "WasteCarriersEngine::KeyPerson"
      embeds_one :metaData,                 class_name: "WasteCarriersEngine::MetaData"

      accepts_nested_attributes_for :addresses,
                                    :conviction_search_result,
                                    :conviction_sign_offs,
                                    :finance_details,
                                    :key_people,
                                    :metaData

      field :accessCode, as: :address_code,                                 type: String
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
      field :receipt_email,                                                 type: String
      field :regIdentifier, as: :reg_identifier,                            type: String
      field :registeredCompanyName, as: :registered_company_name,           type: String
      field :companiesHouseUpdatedAt, as: :companies_house_updated_at,      type: DateTime
      field :registrationType, as: :registration_type,                      type: String
      field :reg_uuid,                                                      type: String # Used by waste-carriers-frontend
      field :uuid,                                                          type: String
      field :email_history,                                                 type: Array, default: []
      field :communications_opted_in,                                       type: Mongoid::Boolean, default: true
      # rubocop:enable Layout/LineLength

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
        if term.present?
          escaped_term = Regexp.escape(term)

          any_of({ reg_identifier: /\A#{escaped_term}\z/i },
                 { company_name: /#{escaped_term}/i },
                 { last_name: /#{escaped_term}/i },
                 { registered_company_name: /#{escaped_term}/i },
                 { phone_number: /#{telephone_regex(term)}/ },
                 "addresses.postcode": /#{escaped_term}/i)
        else
          # Return a valid empty scope if no search term was provided
          none
        end
      }

      scope :not_selected_for_email, ->(template_id) { where.not("email_history.template_id": template_id) }

      scope :upper_tier, -> { where(tier: "UPPER") }
      scope :lower_tier, -> { where(tier: "LOWER") }

      def self.telephone_regex(term)
        # Clone the search term so we can modify it here without impacting other searches
        search_term = term.dup

        # A valid regex guaranteed not to match any values, for skipping phone_number searches
        no_matches_regex = "^.^"
        return no_matches_regex unless term.present?

        # Removing the 0 or +44 at the beginning of the search term as this is handled by the regex
        search_term.gsub!(/^(\+44|0)/, "")

        # Remove any non-digits
        search_term.gsub!(/\D/, "")

        # UK phone numbers excluding the leading zero are either nine or ten digits
        min_digits = 9

        # Avoid trivial matches with search terms intended for other attributes
        # e.g. search "CBDU01" reduces to "01" matching all phone numbers with a "01"
        # Also, searching with an empty value would match all model instances
        return no_matches_regex if search_term.length < min_digits

        # Regex can search for a number with spaces and dashes anywhere and for UK numbers either starting in 0 or +44
        "(\\+44|0|\\+)?[\\s-]*#{search_term.scan(/\d/).map { |c| "#{c}[\\s-]*" }.join}"
      end

      def mobile?
        VerifyIfMobileService.run(phone_number:)
      end

      def charity?
        business_type == "charity"
      end

      def uk_location?
        %w[england scotland wales northern_ireland].include?(location)
      end

      def overseas?
        return false if uk_location?

        location == "overseas" || business_type == "overseas"
      end

      def assisted_digital?
        contact_email.blank?
      end

      def pending_online_payment?
        return false unless finance_details.present? &&
                            finance_details.orders.present? &&
                            finance_details.orders.first.present?

        GovpayValidatorService.valid_govpay_status?(:pending, finance_details.orders.first.govpay_status)
      end

      # Some business types should not have a company_no
      def company_no_required?
        return false if overseas?
        return false if lower_tier?

        %w[limitedCompany limitedLiabilityPartnership].include?(business_type)
      end

      def company_name_required?
        return true if overseas?

        case business_type
        when "limitedCompany", "limitedLiabilityPartnership", "soleTrader"
          # mandatory for lower tier, optional for upper tier
          lower_tier?
        else
          # otherwise mandatory
          true
        end
      end

      def rejected_conviction_checks?
        return false unless conviction_sign_offs&.any?

        conviction_sign_offs.last.rejected?
      end

      def main_people
        return [] unless key_people.present?

        key_people.where(person_type: "KEY")
      end

      def declared_convictions?
        declared_convictions == "yes"
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

      def email_to_send_receipt
        receipt_email || contact_email
      end

      # rubocop and SonarCloud disagree about this
      # rubocop:disable Style/EmptyElse
      def legal_entity_name
        case business_type
        when "limitedCompany", "limitedLiabilityPartnership"
          registered_company_name
        when "soleTrader"
          upper_tier? ? first_person_name : nil
        else
          nil
        end
      end
      # rubocop:enable Style/EmptyElse

      def first_person_name
        return nil unless key_people.present? && key_people[0].present?

        format("%<first>s %<last>s", first: key_people[0].first_name, last: key_people[0].last_name)
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
  # rubocop:enable Metrics/ModuleLength

end
