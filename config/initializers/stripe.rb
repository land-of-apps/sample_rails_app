Rails.configuration.stripe = {
  publishable_key: ENV['STRIPE_PUBLISHABLE_KEY']
}

Stripe.api_key = ENV['STRIPE_SECRET_KEY']