# frozen_string_literal: true

require "ostruct"

module WasteCarriersEngine
  module Govpay
    # Generic Object. Takes the hash/Json returned from the Govpay API
    # and gives us openstruct objects for easier reading/consuming
    class Object < OpenStruct
      def initialize(attributes)
        super to_ostruct(attributes)
      end

      def to_ostruct(obj)
        if obj.is_a?(Hash)
          OpenStruct.new(obj.transform_values { |v| to_ostruct(v) })
        elsif obj.is_a?(Array)
          obj.map { |o| to_ostruct(o) }
        elsif obj.is_a?(String)
          string_reader(obj)&.strip
        else # Likely a primative value
          obj
        end
      end

      def string_reader(value)
        return if nil_value?(value)

        value = value.to_s
        value = yield value if block_given?

        value
      end

      def nil_value?(value)
        value.nil? ||
          %w[nil null].any?(
            value
              .to_s
              .strip
              .downcase
          )
      end
    end
  end
end
