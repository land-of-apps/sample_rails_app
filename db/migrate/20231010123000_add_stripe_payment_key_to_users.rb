class AddStripePaymentKeyToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :stripe_payment_key, :string
  end
end
