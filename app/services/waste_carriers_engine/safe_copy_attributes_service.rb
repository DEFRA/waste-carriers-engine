# frozen_string_literal: true

module WasteCarriersEngine
  # This responsible for safely copying attributes and embedded relations from a source instance of
  # one class to a new instance of the targeted class. By default it will copy every attribute except _id
  # and every embedded relation that are defined in the target class. However, both attributes and embedded
  # relations can be excluded by passing them into the attributes_to_exclude argument
  # Embedded relations are processed recursively, and attributes to exclude
  # will be applied to the embedded relations as well.

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
        # Skip if the relation is in the attributes_to_exclude list
        next if @attributes_to_exclude.map(&:underscore).include?(relation_name.underscore)

        # Find the corresponding key in attributes (handles snake_case and camelCase)
        key = matching_attribute_key(attributes, relation_name)
        next unless key

        source_data = attributes[key]
        embedded_class = relation_metadata.class_name.constantize
        embedded_attributes[key] = process_embedded_data(source_data, embedded_class)
      end

      embedded_attributes
    end

    # Finds the attribute key in attributes that corresponds to the relation name
    def matching_attribute_key(attributes, relation_name)
      snake_case_name = relation_name.underscore
      camel_case_name = relation_name.camelize(:lower)

      if attributes.key?(snake_case_name)
        snake_case_name
      elsif attributes.key?(camel_case_name)
        camel_case_name
      end
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
