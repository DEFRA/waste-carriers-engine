# frozen_string_literal: true

module WasteCarriersEngine
  module CanReferenceSingleDocumentInCollection
    extend ActiveSupport::Concern

    class_methods do
      def reference_one(attribute_name, collection:, find_by:)
        define_method(attribute_name) do
          retrieve_attribute(attribute_name, collection, find_by)
        end

        define_method("#{attribute_name}=") do |new_object|
          assign_attribute(attribute_name, collection, find_by, new_object)
        end
      end
    end

    included do
      def retrieve_attribute(attribute_name, collection, find_by)
        instance_variable_get("@#{attribute_name}") ||
          fetch_attribute(attribute_name, collection, find_by)
      end

      def assign_attribute(attribute_name, collection, find_by, new_object)
        eval("#{attribute_name}.delete") if send(attribute_name)
        eval("#{collection} << new_object")

        instance_variable_set("@#{attribute_name}", nil)
      end

      def fetch_attribute(attribute_name, collection, find_by)
        criteria = instance_eval("#{collection}.criteria")

        criteria.where(find_by).first
      end
    end
  end
end
