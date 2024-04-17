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
        embedded_documents: %w[metaData],
        attributes_to_exclude: options[:ignorable_attributes]
      )
      assign_attributes(strip_whitespace(attributes))
    end

    def remove_revoked_reason
      metaData.revoked_reason = nil
    end

    def options
      @_options ||= self.class::COPY_DATA_OPTIONS
    end
  end
end
