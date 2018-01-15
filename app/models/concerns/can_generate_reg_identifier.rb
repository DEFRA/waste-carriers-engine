module CanGenerateRegIdentifier
  extend ActiveSupport::Concern

  def generate_reg_identifier
    # Use the existing reg_identifier if one is already set, eg. through seeding
    return if reg_identifier

    # Get the counter for reg_identifiers, or create it if it doesn't exist
    counter = Counter.where(_id: "regid").first || Counter.create(_id: "regid", seq: 1)

    # Increment the counter until no reg_identifier is using it
    while Registration.where(reg_identifier: "CBDU#{counter.seq}").exists? || Registration.where(reg_identifier: "CBDL#{counter.seq}").exists?
      counter.increment
    end

    self.reg_identifier = if tier == "UPPER"
                            "CBDU#{counter.seq}"
                          elsif tier == "LOWER"
                            "CBDL#{counter.seq}"
                          end
  end
end
