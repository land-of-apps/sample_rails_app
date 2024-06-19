class BillingAddress
  include Mongoid::Document
  include Mongoid::Timestamps
  field :user_id, type: Integer
  field :line1, type: String
  field :line2, type: String
  field :city, type: String
  field :state, type: String
  field :zip, type: String
  field :country, type: String

  validates :line1, :city, :state, :zip, :country, presence: true
end
