class UserBilling
  include Mongoid::Document

  field :user_id, type: Integer
  field :address, type: String
  field :city, type: String
  field :state, type: String
  field :zip_code, type: String

  index({ user_id: 1 }, { unique: true, name: "user_id_index" })

  validates_presence_of :user_id, :address, :city, :state, :zip_code
end
