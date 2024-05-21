class PaymentsController < ApplicationController
  before_action :logged_in_user

  def create_session
    session = Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      line_items: [{
        price_data: {
          currency: 'usd',
          product_data: {
            name: 'Micropost Pro',
          },
          unit_amount: 1000,
        },
        quantity: 1,
      }],
      mode: 'payment',
      success_url: success_payments_url + '?session_id={CHECKOUT_SESSION_ID}',
      cancel_url: cancel_payments_url
    )

    respond_to do |format|
      format.json { render json: { id: session.id } }
    end
  rescue Stripe::InvalidRequestError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def success
    # Handle successful payment and subscription logic
    flash[:success] = "Payment successful and subscription started!"
    redirect_to settings_path
  end

  def cancel
    # Handle subscription cancellation logic
    flash[:warning] = "Payment was cancelled."
    redirect_to settings_path
  end

  def cancel_subscription
    customer = Stripe::Customer.retrieve(current_user.stripe_customer_id)
    subscription = customer.subscriptions.data[0]
    subscription.delete
    flash[:success] = "Subscription cancelled."
    redirect_to settings_path
  end

  def subscription_status
    customer = Stripe::Customer.retrieve(current_user.stripe_customer_id)
    subscription = customer.subscriptions.data[0]
    @subscription_active = subscription && subscription.status == 'active'
  end

  private

  def user_params
    params.require(:user).permit(:stripe_customer_id)
  end
end
