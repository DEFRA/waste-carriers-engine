# frozen_string_literal: true

module WasteCarriersEngine
  class Counter
    include Mongoid::Document

    store_in collection: "counters"

    field :seq, type: Integer
  end
end
