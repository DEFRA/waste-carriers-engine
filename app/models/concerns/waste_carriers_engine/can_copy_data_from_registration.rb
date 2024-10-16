# frozen_string_literal: true

module WasteCarriersEngine
  module CanCopyDataFromRegistration
    extend ActiveSupport::Concern

    included do
      after_initialize :copy_data_from_registration, if: -> { new_record? && valid? }
    end

    def copy_data_from_registration
      copy_attributes_from_registration
      copy_addresses_from_registration if options[:copy_addresses]
      copy_people_from_registration if options[:copy_people]
      remove_revoked_reason if options[:remove_revoked_reason]
    end

    def copy_attributes_from_registration
      # Omit addresses and key_people from embedded_documents as these will/won't be
      # copied separately depending on options passed by the class using this concern
      attributes = SafeCopyAttributesService.run(
        source_instance: registration,
        target_class: self.class,
        attributes_to_exclude: options[:ignorable_attributes]
      )
      assign_attributes(strip_whitespace(attributes))
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

    def remove_revoked_reason
      metaData.revoked_reason = nil
    end

    def options
      @_options ||= self.class::COPY_DATA_OPTIONS
    end
  end
end
