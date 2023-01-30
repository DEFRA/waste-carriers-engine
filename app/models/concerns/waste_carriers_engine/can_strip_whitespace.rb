# frozen_string_literal: true

module WasteCarriersEngine
  # Used to clean up excess whitespace from the start and end of fields
  module CanStripWhitespace
    extend ActiveSupport::Concern

    # Expects a hash of attributes or a Mongoid object
    def strip_whitespace(attributes)
      # Loop over each value and strip the whitespace, or strip the whitespace from values nested within it
      attributes.each_pair do |key, value|
        case value
        when String
          attributes[key] = strip_string(value)
        when Hash
          strip_hash(value)
        when Array
          strip_array(value)
        else
          value
        end
      end
    end

    private

    def strip_string(string)
      string.strip
    end

    def strip_hash(hash)
      strip_whitespace(hash)
    end

    def strip_array(array)
      array.each do |nested_object|
        return nested_object if nested_object.is_a? BSON::Document

        strip_whitespace(nested_object.attributes)
      end
    end
  end
end
