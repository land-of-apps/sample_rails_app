class SettingsController < ApplicationController
  before_action :logged_in_user

  def show
    if current_user.stripe_customer_id.present?
      customer = Stripe::Customer.retrieve(current_user.stripe_customer_id)
      subscription = customer.subscriptions.data[0]
      @subscription_active = subscription && subscription.status == 'active'
    else
      @subscription_active = false
      flash[:warning] = "No Stripe customer ID found. Please set up your payment method."
    end
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(user_params)
      flash[:success] = "Settings updated"
      redirect_to settings_path
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :stripe_payment_key) # Add any other necessary params
  end
end
