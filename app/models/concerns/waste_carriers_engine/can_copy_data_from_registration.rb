# frozen_string_literal: true

module WasteCarriersEngine
  module CanCopyDataFromRegistration
    extend ActiveSupport::Concern

    included do
      after_initialize :copy_data_from_registration, if: :new_record?
    end

    private

    def copy_data_from_registration
      # Don't try to get Registration data with an invalid reg_identifier
      return unless valid? && new_record?

      # Don't copy object IDs as Mongo should generate new unique ones
      attributes = registration.attributes.except("_id",
                                                  "addresses",
                                                  "key_people",
                                                  "financeDetails",
                                                  "conviction_search_result",
                                                  "conviction_sign_offs",
                                                  "declaration",
                                                  "past_registrations",
                                                  "copy_cards")

      assign_attributes(strip_whitespace(attributes))

      copy_addresses_from_registration
      copy_people_from_registration
    end

    def copy_addresses_from_registration
      registration.addresses.each do |address|
        addresses << Address.new(address.attributes.except("_id"))
      end
    end

    def copy_people_from_registration
      registration.key_people.each do |key_person|
        key_people << KeyPerson.new(key_person.attributes.except("_id", "conviction_search_result"))
      end
    end
  end
end
