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

      # rubocop:disable Lint/UnusedMethodArgument
      def assign_attribute(attribute_name, collection, new_object)
        send(attribute_name)&.delete

        instance_eval("#{collection} << new_object", __FILE__, __LINE__)

        instance_variable_set("@#{attribute_name}", nil)
      end
      # rubocop:enable Lint/UnusedMethodArgument

      def fetch_attribute(collection, find_by)
        criteria = instance_eval("#{collection}.criteria", __FILE__, __LINE__)

        criteria.where(find_by).first
      end
    end
  end
end
