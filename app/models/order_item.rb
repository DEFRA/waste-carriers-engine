class OrderItem
  include Mongoid::Document

  embedded_in :order

  # TODO: Confirm types
  field :amount,                          type: Integer
  field :currency,                        type: String
  field :lastUpdated, as: :last_updated,  type: DateTime # Is this in use?
  field :description,                     type: String
  field :reference,                       type: String
  field :type,                            type: String
end
