# frozen_string_literal: true

module WasteCarriersEngine
  class SafeCopyAttributesService < BaseService
    attr_accessor :source_instance, :target_class, :embedded_documents, :attributes_to_exclude

    def run(source_instance:, target_class:, embedded_documents: [], attributes_to_exclude: [])
      @source_instance = source_instance
      @target_class = target_class
      @embedded_documents = embedded_documents
      @attributes_to_exclude = attributes_to_exclude
      safe_copy_attributes(source_instance, target_class)
    end

    private

    def safe_copy_attributes(source, target_class)
      attributes = get_attributes(source)
      filtered_attributes = filter_attributes(attributes, target_class)

      embedded_documents.each do |doc_name|
        camel_doc_name = doc_name.camelize(:lower)
        snake_doc_name = doc_name.underscore

        if attributes.key?(camel_doc_name) || attributes.key?(snake_doc_name)
          embedded_relation = find_embedded_relation(target_class, doc_name)
          next unless embedded_relation

          embedded_class = embedded_relation.class_name.constantize
          embedded_data = attributes[camel_doc_name] || attributes[snake_doc_name]

          if embedded_data.is_a?(Array)
            filtered_attributes[embedded_relation.name.to_s] = embedded_data.map do |embedded_doc|
              safe_copy_attributes(embedded_doc, embedded_class)
            end
          elsif embedded_data.is_a?(Hash)
            filtered_attributes[embedded_relation.name.to_s] = safe_copy_attributes(embedded_data, embedded_class)
          end
        end
      end

      filtered_attributes
    end

    def find_embedded_relation(target_class, doc_name)
      target_class.embedded_relations.values.find do |relation|
        relation.name.to_s == doc_name.underscore || relation.store_as == doc_name
      end
    end

    def get_attributes(source)
      if source.is_a?(Hash) || source.is_a?(BSON::Document)
        source.to_h
      elsif source.respond_to?(:attributes)
        source.attributes
      else
        raise ArgumentError, "Unsupported source type: #{source.class}"
      end
    end

    def filter_attributes(attributes, klass)
      valid_fields = target_fields(klass)
      attributes.select { |k, _| valid_fields.include?(k) || valid_fields.include?(k.to_s) }
               .except(*attributes_to_exclude)
    end

    def target_fields(klass)
      @target_fields ||= {}
      @target_fields[klass] ||= begin
        fields = klass.fields.keys
        (fields + fields.map(&:underscore) + fields.map { |f| f.camelize(:lower) }).uniq
      end
    end
  end
end
