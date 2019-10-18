# frozen_string_literal: true

# This module's aim is to implement a way to reference a single document in a
# collection so that they can then be treated as `has_one` associations.
# In projects using ActiveRecord like WEX we achieve the same functionality
# thanks to ActiveRecord's Relation ability to specify custom associations using
# default scopes. But because here we are using an old version of MongoDB, we
# are also stuck with a version of Mongoid which does not have this ability.
module WasteCarriersEngine
  module CanReferenceSingleDocumentInCollection
    extend ActiveSupport::Concern

    class_methods do
      def reference_one(attribute_name, collection:, find_by:)
        define_method(attribute_name) do
          retrieve_attribute(attribute_name, collection, find_by)
        end

        define_method("#{attribute_name}=") do |new_object|
          assign_attribute(attribute_name, collection, new_object)
        end
      end
    end

    included do
      def retrieve_attribute(attribute_name, collection, find_by)
        instance_variable_get("@#{attribute_name}") ||
          fetch_attribute(collection, find_by)
      end

      def assign_attribute(attribute_name, collection, new_object)
        new_collection = public_send(collection) || []

        new_collection -= [public_send(attribute_name)]
        new_collection << new_object

        public_send("#{collection}=", new_collection)
      end

      def fetch_attribute(collection, find_by)
        public_send(collection).each do |element|
          find_by.each do |key, value|
            return element if element.public_send(key) == value
          end
        end

        nil
      end
    end
  end
end
