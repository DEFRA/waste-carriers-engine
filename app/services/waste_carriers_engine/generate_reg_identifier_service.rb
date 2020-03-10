# frozen_string_literal: true

module WasteCarriersEngine
  class GenerateRegIdentifierService < BaseService
    def run
      # Get the counter for reg_identifiers, or create it if it doesn't exist
      counter = Counter.where(_id: "regid").first || Counter.create(_id: "regid", seq: 1)

      # Increment the counter until no reg_identifier is using it
      counter.increment while Registration.where(reg_identifier: /CBD[U|L]#{counter.seq}/).exists?

      counter.seq
    end
  end
end
