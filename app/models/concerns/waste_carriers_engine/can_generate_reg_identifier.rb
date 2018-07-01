module WasteCarriersEngine
  module CanGenerateRegIdentifier
    extend ActiveSupport::Concern

    def generate_reg_identifier
      # Use the existing reg_identifier if one is already set, eg. through seeding
      return if reg_identifier

      self.reg_identifier = if tier == "UPPER"
                              "CBDU#{latest_counter}"
                            elsif tier == "LOWER"
                              "CBDL#{latest_counter}"
                            end
    end

    private

    def latest_counter
      # Get the counter for reg_identifiers, or create it if it doesn't exist
      counter = Counter.where(_id: "regid").first || Counter.create(_id: "regid", seq: 1)

      # Increment the counter until no reg_identifier is using it
      while Registration.where(reg_identifier: /CBD[U|L]#{counter.seq}/).exists?
        counter.increment
      end

      counter.seq
    end
  end
end
