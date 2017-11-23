class Registration
  include Mongoid::Document

  embeds_one :metaData
  embeds_many :addresses
  embeds_many :keyPeople
  embeds_one :financeDetails
  embeds_one :convictionSearchResult
  embeds_many :conviction_sign_offs

  accepts_nested_attributes_for :metaData,
                                :addresses,
                                :keyPeople,
                                :financeDetails,
                                :convictionSearchResult,
                                :conviction_sign_offs

  field :uuid,                    type: String
  field :tier,                    type: String
  field :registrationType,        type: String
  field :businessType,            type: String
  field :otherBusinesses,         type: Boolean
  field :isMainService,           type: Boolean
  field :onlyAMF,                 type: Boolean
  field :companyName,             type: String
  field :companyNo,               type: Integer
  field :firstName,               type: String
  field :lastName,                type: String
  field :phoneNumber,             type: String
  field :contactEmail,            type: String
  field :accountEmail,            type: String
  field :declaredConvictions,     type: Boolean
  field :declaration,             type: Integer # Unsure of type
  field :regIdentifier,           type: String
  field :expiresOn,               type: DateTime

  validates :regIdentifier,
            :addresses,
            :metaData,
            presence: true
end
