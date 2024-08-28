require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require 'opentelemetry/instrumentation/rails'
require 'opentelemetry/instrumentation/active_record'

module SampleRailsApp
  class Application < Rails::Application
    config.load_defaults 7.0

    # Enable OpenTelemetry instrumentation
    OpenTelemetry::Instrumentation::Rails::Instrumentation.instance.install(config: { request_hooks: [] })
    OpenTelemetry::Instrumentation::ActiveRecord::Instrumentation.instance.install
    OpenTelemetry::Instrumentation::Net::HTTP::Instrumentation.instance.install
  end
end
