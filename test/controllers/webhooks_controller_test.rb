# test/controllers/webhooks_controller_test.rb
require "test_helper"

class WebhooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:michael)
    @stripe_event = {
      "id" => "evt_123",
      "type" => "checkout.session.completed",
      "data" => {
        "object" => {
          "metadata" => {
            "user_id" => @user.id
          }
        }
      }
    }.to_json

    timestamp = Time.now

    # Update the signature computation
    @signature = Stripe::Webhook::Signature.compute_signature(
      timestamp,
      @stripe_event,
      Rails.configuration.stripe[:webhook_secret]
    )
    
    @headers = {
      'HTTP_STRIPE_SIGNATURE' => "t=#{timestamp.to_i},v1=#{@signature}",
      'Content-Type' => 'application/json'
    }
  end

  test "stripe webhook should update user payment status" do
    post webhook_stripe_path, headers: @headers, params: @stripe_event
    assert_response :success
    @user.reload
    assert @user.paid
  end
end
