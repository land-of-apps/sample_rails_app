class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def stripe
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    event = nil
    webhook_secret = Rails.configuration.stripe[:webhook_secret]

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, webhook_secret)
    rescue JSON::ParserError => e
      render status: 400, json: { error: "Invalid payload" }
      return
    rescue Stripe::SignatureVerificationError => e
      render status: 400, json: { error: "Invalid signature" }
      return
    end

    handle_event(event)
    render json: { status: "success" }
  end

  private

  def handle_event(event)
    case event['type']
    when 'checkout.session.completed'
      session = event['data']['object']
      user = User.find(session.metadata.user_id)
      user.update(paid: true)
    end
  end
end
