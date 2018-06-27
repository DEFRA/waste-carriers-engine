class ConvictionSignOff
  include Mongoid::Document

  embedded_in :registration
  embedded_in :past_registration

  field :confirmed,                       type: Boolean
  field :confirmedAt, as: :confirmed_at,  type: DateTime
  field :confirmedBy, as: :confirmed_by,  type: String
end
