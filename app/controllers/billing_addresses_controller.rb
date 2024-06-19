class BillingAddressesController < ApplicationController
  before_action :set_user

  def show
    Rails.logger.info "Showing the billing address for user ID: #{@user.id}"
    
    @billing_address = @user.billing_address
    if @billing_address.nil?
      Rails.logger.warn "No billing address found for user ID: #{@user.id}, creating a new one."
      @billing_address = BillingAddress.new
    else
      Rails.logger.info "Billing address loaded successfully for user ID: #{@user.id}"
    end

    render 'show'
  end

  def create
    @billing_address = @user.billing_address

    if @billing_id_address.nil?
      @billing_address = BillingAddress.new(billing_address_params)
      @billing_address.user_id = @user.id 
    end

    if @billing_address.update(billing_address_params)
      redirect_to billing_address_path(@user), notice: 'Billing address was successfully updated.'
    else
      render :show, status: :unprocessable_entity
    end
  end

  def update
    @billing_address = @user.billing_address || @user.build_billing_address
    if @billing_address.update(billing_address_params)
      redirect_to billing_address_path(@user), notice: 'Billing address was successfully updated.'
    else
      render 'show', status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end


  def billing_address_params
    params.require(:billing_address).permit(:line1, :line2, :city, :state, :zip, :country)
  end

end
