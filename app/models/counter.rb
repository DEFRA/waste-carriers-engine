class Counter
  include Mongoid::Document

  field :_id, type: String
  field :seq, type: Integer

  def increment
    new_seq = seq + 1
    update_attributes(seq: new_seq)
  end
end
