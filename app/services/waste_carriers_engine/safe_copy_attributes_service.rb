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

    def copy_attributes(source_instance, target_class)
      attributes = extract_attributes(source_instance)

      # Filter attributes / embedded relations to only those defined in
      # the target class, excluding '_id' AND any attributes
      # specified in attributes_to_exclude
      valid_attributes = filter_attributes(attributes, target_class)

      # Process each embedded relation defined in the target class
      target_class.embedded_relations.each do |relation_name, relation_metadata|
        # Match the source relation data to a relation embedded in the target class
        # handle source data being camelCase or snake_case
        if (source_relation_data = attributes[relation_name.underscore])
          original_relation_name = relation_name.underscore
        elsif (source_relation_data = attributes[relation_name.camelize(:lower)])
          original_relation_name = relation_name.camelize(:lower)
        else
          # Proceed only if there is a match
          next
        end

        embedded_class = relation_metadata.class_name.constantize

        valid_attributes[original_relation_name] = process_embedded_data(
          source_relation_data,
          embedded_class
        )
      end

      valid_attributes
    end

    def extract_attributes(source_instance)
      if source_instance.is_a?(Hash) || source_instance.is_a?(BSON::Document)
        source_instance.to_h.stringify_keys
      elsif source_instance.respond_to?(:attributes)
        source_instance.attributes
      else
        raise ArgumentError, "Unsupported source_instance type: #{source_instance.class}"
      end
    end

    def filter_attributes(attributes, target_class)
      target_field_names = target_class.fields.keys.map(&:to_s)
      attributes.slice(*target_field_names).except("_id").except(*@attributes_to_exclude)
    end

    def process_embedded_data(data, embedded_class)
      # Recursively process embedded data
      if data.is_a?(Array)
        data.map { |item| copy_attributes(item, embedded_class) }
      elsif data.is_a?(Hash) || data.is_a?(BSON::Document)
        copy_attributes(data, embedded_class)
      end
    end
  end
end
