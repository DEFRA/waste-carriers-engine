# frozen_string_literal: true

module WasteCarriersEngine
  module CanCopyDataFromRegistration
    extend ActiveSupport::Concern

    included do
      after_initialize :copy_data_from_registration, if: :new_record?
    end

    def copy_data_from_registration
      # Don't try to get Registration data with an invalid reg_identifier
      return unless valid? && new_record?

      # Don't copy object IDs as Mongo should generate new unique ones
      attributes = registration.attributes.except(*options[:ignorable_attributes])

      assign_attributes(strip_whitespace(attributes))

      copy_addresses_from_registration if options[:copy_addresses]
      copy_people_from_registration if options[:copy_people]
      remove_invalid_attributes if options[:remove_invalid_attributes]
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

    def remove_invalid_attributes
      remove_invalid_phone_numbers
      remove_revoked_reason
    end

    def remove_invalid_phone_numbers
      validator = DefraRuby::Validators::PhoneNumberValidator.new(attributes: :phone_number)
      return if validator.validate_each(self, :phone_number, phone_number)

      self.phone_number = nil
    end

    def remove_revoked_reason
      metaData.revoked_reason = nil
    end

    def options
      @_options ||= self.class::COPY_DATA_OPTIONS
    end
  end
end
