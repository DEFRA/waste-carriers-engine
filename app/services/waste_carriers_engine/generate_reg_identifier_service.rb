# frozen_string_literal: true

module WasteCarriersEngine
  class GenerateRegIdentifierService < BaseService
    def run
      counter_context = Counter.where(_id: "regid")

      Counter.create(_id: "regid", seq: 1) unless counter_context.any?

      counter = counter_context.find_one_and_update("$inc" => { seq: 1 })

      while Registration.where(reg_identifier: /CBD[U|L]#{counter.seq}/).exists?
        counter = counter_context.find_one_and_update("$inc" => { seq: 1 })
      end

      counter.seq
    end
  end
end
