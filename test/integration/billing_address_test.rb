# test/integration/billing_address_test.rb
require "test_helper"

class BillingAddressTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test "create new billing address" do
    # Ensure no billing address exists before this test
    UserBilling.where(user_id: @user.id).destroy_all

    get billing_user_path(@user)
    assert_template 'users/billing'
    
    assert_difference 'UserBilling.count', 1 do
      patch billing_user_path(@user), params: { billing: { address: "123 Main Street", city: "Sample City", state: "SC", zip_code: "12345" } }
    end

    assert_redirected_to billing_user_path(@user)
    follow_redirect!
    assert_match "Billing address updated", response.body
  end

  test "update existing billing address" do
    # Ensure a billing address exists before this test
    UserBilling.create(user_id: @user.id, address: "Initial Address", city: "Initial City", state: "Initial State", zip_code: "00000")

    get billing_user_path(@user)
    assert_template 'users/billing'

    assert_no_difference 'UserBilling.count' do
      patch billing_user_path(@user), params: { billing: { address: "456 Another St", city: "Updated City", state: "UC", zip_code: "67890" } }
    end

    assert_redirected_to billing_user_path(@user)
    follow_redirect!
    assert_match "Billing address updated", response.body

    # Verify the attributes are updated
    @user.reload
    assert_equal "456 Another St", @user.billing_address.address
    assert_equal "Updated City", @user.billing_address.city
    assert_equal "UC", @user.billing_address.state
    assert_equal "67890", @user.billing_address.zip_code
  end
end
