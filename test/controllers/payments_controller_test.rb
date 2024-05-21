require 'test_helper'

class PaymentsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    log_in_as(@user)
  end

  test "should get new session" do
    post create_session_payments_path, as: :json
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_match /cs_test/, json_response['id']
  end

  test "should handle successful payment" do
    get success_payments_path
    assert_redirected_to settings_path
    assert_not flash[:success].empty?
  end

  test "should handle payment cancellation" do
    get cancel_payments_path
    assert_redirected_to settings_path
    assert_not flash[:warning].empty?
  end
end
