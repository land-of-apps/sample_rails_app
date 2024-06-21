require "test_helper"

class BillingAddressTest < ActionDispatch::IntegrationTest
  def setup
    @michael = users(:michael)
    @archer = users(:archer)
    Mongoid.raise_not_found_error = false
  end

  test "create new billing address" do
    user = @michael
    UserBilling.find_by(user_id: user.id)&.destroy
    get billing_user_path(user)
    assert_template 'users/billing'

    patch billing_user_path(user), params: { billing: { address: "123 Main Street", city: "Sample City", state: "SC", zip_code: "12345" } }

    assert_redirected_to billing_user_path(user)
    follow_redirect!
    assert_match "Billing address updated", response.body
    user.reload
    user_billing = UserBilling.find_by(user_id: user.id)
    assert_not_nil user_billing
    assert_equal "123 Main Street", user_billing.address
    assert_equal "Sample City", user_billing.city
    assert_equal "SC", user_billing.state
    assert_equal "12345", user_billing.zip_code
  end

  test "update existing billing address" do
    user = @archer
    UserBilling.find_by(user_id: user.id)&.destroy
    UserBilling.create(user_id: user.id, address: "Initial Address", city: "Initial City", state: "Initial State", zip_code: "00000")

    get billing_user_path(user)
    assert_template 'users/billing'

    patch billing_user_path(user), params: { billing: { address: "456 Another St", city: "Updated City", state: "UC", zip_code: "67890" } }

    assert_redirected_to billing_user_path(user)
    follow_redirect!
    assert_match "Billing address updated", response.body

    # Verify the attributes are updated
    user.reload
    user_billing = UserBilling.find_by(user_id: user.id)
    assert_not_nil user_billing
    assert_equal "456 Another St", user_billing.address
    assert_equal "Updated City", user_billing.city
    assert_equal "UC", user_billing.state
    assert_equal "67890", user_billing.zip_code
  end
end
