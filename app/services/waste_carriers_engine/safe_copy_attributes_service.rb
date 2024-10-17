# frozen_string_literal: true

module WasteCarriersEngine
  class SafeCopyAttributesService
    def self.run(source_instance:, target_class:, attributes_to_exclude: [])
      new(source_instance, target_class, attributes_to_exclude).run
    end

    def initialize(source_instance, target_class, attributes_to_exclude = [])
      @source_instance = source_instance
      @target_class = target_class
      @attributes_to_exclude = attributes_to_exclude
    end

    def run
      copy_attributes(@source_instance, @target_class)
    end

    private

    # Recursively copies attributes from the source to match the target class
    def copy_attributes(source, target_class)
      attributes = extract_attributes(source)
      valid_attributes = filter_attributes(attributes, target_class)
      embedded_attributes = process_embedded_relations(attributes, target_class)
      valid_attributes.merge(embedded_attributes)
    end

    # Extracts attributes from the source instance based on its type
    def extract_attributes(source)
      case source
      when Hash, BSON::Document
        source.to_h.stringify_keys
      when ->(obj) { obj.respond_to?(:attributes) }
        source.attributes
      else
        raise ArgumentError, "Unsupported source_instance type: #{source.class}"
      end
    end

    # Filters attributes to include only those defined in the target class, excluding specified attributes
    def filter_attributes(attributes, target_class)
      target_fields = target_class.fields.keys.map(&:to_s)
      attributes.slice(*target_fields).except("_id", *@attributes_to_exclude)
    end

    # Processes embedded relations defined in the target class
    def process_embedded_relations(attributes, target_class)
      embedded_attributes = {}

      target_class.embedded_relations.each do |relation_name, relation_metadata|
        source_data, key = find_relation_data(attributes, relation_name)
        next unless source_data

        embedded_class = relation_metadata.class_name.constantize
        embedded_attributes[key] = process_embedded_data(source_data, embedded_class)
      end

      embedded_attributes
    end

    # Finds the relation data in the source attributes, handling different naming conventions
    def find_relation_data(attributes, relation_name)
      keys_to_check = [relation_name.underscore, relation_name.camelize(:lower)]
      key = keys_to_check.find { |k| attributes.key?(k) }
      [attributes[key], key] if key
    end

    # Recursively processes embedded data
    def process_embedded_data(data, embedded_class)
      if data.is_a?(Array)
        data.map { |item| copy_attributes(item, embedded_class) }
      elsif data.is_a?(Hash) || data.is_a?(BSON::Document)
        copy_attributes(data, embedded_class)
      end
    end
  end
end
