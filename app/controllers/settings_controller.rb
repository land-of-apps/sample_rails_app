class SettingsController < ApplicationController
  before_action :logged_in_user

  def show
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
