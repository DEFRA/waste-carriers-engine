# frozen_string_literal: true

module WasteCarriersEngine
  module MongoidMonkeyPatch
    def pending_attribute?(key, value)
      name = key.to_s

      aliased = if aliased_associations.key?(name)
                  aliased_associations[name]
                else
                  name
                end

      if relations.key?(aliased)
        pending_relations[aliased.to_s] = value
        return true
      end
      if nested_attributes.key?(aliased)
        pending_nested[name] = value
        return true
      end
      false
    end
  end
end

module Mongoid
  module Attributes
    module Processing
      prepend WasteCarriersEngine::MongoidMonkeyPatch
    end
  end
end
