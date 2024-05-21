# frozen_string_literal: true

module WasteCarriersEngine
  class SafeCopyAttributesService < BaseService

    attr_accessor :source_instance, :target_class, :embedded_documents, :attributes_to_exclude

    def run(source_instance:, target_class:, embedded_documents: [], attributes_to_exclude: [])
      @source_instance = source_instance
      @target_class = target_class
      @embedded_documents = embedded_documents
      @attributes_to_exclude = attributes_to_exclude

      source_attributes.except(*unsupported_attribute_keys)
    end

    def source_attributes
      attributes = source_instance.is_a?(BSON::Document) ? source_instance : source_instance.attributes

      attributes.except(*attributes_to_exclude)
    end

    def target_fields
      # Include both camelCase (DB) and snake_case (model) attribute names:
      (target_class.fields.keys + target_class.fields.keys.map(&:underscore)).uniq
    end

    def unsupported_attribute_keys
      source_attributes.except(*target_fields).excluding(embedded_documents).keys
    end
  end
end
