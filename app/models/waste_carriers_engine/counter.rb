# frozen_string_literal: true

module WasteCarriersEngine
  class Counter
    include Mongoid::Document

    field :seq, type: Integer

    def increment
      new_seq = seq + 1
      update_attributes(seq: new_seq)
    end
  end
end
