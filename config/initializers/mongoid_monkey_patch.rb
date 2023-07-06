module Mongoid
  module Attributes
    module Processing
      def pending_attribute?(key, value)
        name = key.to_s

        aliased = if aliased_associations.key?(name)
                    aliased_associations[name]
                  else
                    name
                  end

        if relations.has_key?(aliased)
          pending_relations[aliased.to_s] = value
          return true
        end
        if nested_attributes.has_key?(aliased)
          pending_nested[name] = value
          return true
        end
        return false
      end
    end
  end
end
