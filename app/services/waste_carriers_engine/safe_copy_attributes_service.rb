# frozen_string_literal: true

module WasteCarriersEngine
  class SafeCopyAttributesService
    def self.run(source_instance:, target_class:)
      new(source_instance, target_class).run
    end

    def initialize(source_instance, target_class)
      @source_instance = source_instance
      @target_class = target_class
    end

    def run
      copy_attributes(@source_instance, @target_class)
    end

    private

    def copy_attributes(source_instance, target_class)
      attributes = extract_attributes(source_instance)

      # Filter attributes to only those defined in the target class, excluding '_id'
      valid_attributes = filter_attributes(attributes, target_class)

      # Process each embedded relation defined in the target class
      target_class.embedded_relations.each do |relation_name, relation_metadata|
        source_relation_data = attributes[relation_name.to_s]

        next unless source_relation_data

        embedded_class = relation_metadata.class_name.constantize

        valid_attributes[relation_name.to_s] = process_embedded_data(
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
      attributes.slice(*target_field_names).except('_id')
    end

    def process_embedded_data(data, embedded_class)
      if data.is_a?(Array)
        data.map { |item| copy_attributes(item, embedded_class) }
      elsif data.is_a?(Hash) || data.is_a?(BSON::Document)
        copy_attributes(data, embedded_class)
      else
        nil
      end
    end
  end
end
