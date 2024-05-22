# test/system/stripe_payment_flow_test.rb
require "application_system_test_case"

class StripePaymentFlowTest < ApplicationSystemTestCase
  def setup
    @user = users(:michael)
  end

  test "end-to-end payment flow" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_text "Pro Membership"
    stripe_event = {
      "type" => "checkout.session.completed",
      "data" => {
        "object" => {
          "metadata" => {
            "user_id" => @user.id
          }
        }
      }
    }
    signature = Stripe::Webhook::Signature.compute(stripe_event.to_json, Rails.configuration.stripe[:webhook_secret])
    post webhook_stripe_path, headers: { 'HTTP_STRIPE_SIGNATURE' => signature }, params: stripe_event.to_json

    @user.reload
    assert @user.paid
  end
end
