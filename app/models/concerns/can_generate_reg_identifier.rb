module CanGenerateRegIdentifier
  extend ActiveSupport::Concern

  def generate_reg_identifier
    # Use the existing reg_identifier if one is already set, eg. through seeding
    return if reg_identifier

    # Get the counter for reg_identifiers, or create it if it doesn't exist
    counter = Counter.where(_id: "regid").first || Counter.create(_id: "regid", seq: 0)

    # Increment the counter and get the updated value
    counter.increment
    number = counter.seq

    self.reg_identifier = if tier == "UPPER"
                            "CBDU#{number}"
                          elsif tier == "LOWER"
                            "CBDL#{number}"
                          end
  end
end
