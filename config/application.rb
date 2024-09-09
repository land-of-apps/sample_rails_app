require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require 'opentelemetry/instrumentation/rails'
require 'opentelemetry/instrumentation/active_record'
require_relative '../lib/otel_logger_formatter' 

module SampleRailsApp
  class Application < Rails::Application
    config.load_defaults 7.0
    config.logger = ActiveSupport::Logger.new('log/production.log')
    config.logger.formatter = OtelLoggerFormatter.new

    # Custom logger that includes OpenTelemetry trace information
    config.logger.formatter = proc do |severity, datetime, progname, msg|
      span_context = OpenTelemetry::Trace.current_span.context
      trace_id = span_context.hex_trace_id
      span_id = span_context.hex_span_id
      trace_flags = span_context.trace_flags

      "[#{datetime}] #{severity} (trace_id=#{trace_id} span_id=#{span_id} trace_flags=#{trace_flags}): #{progname} #{msg}\n"
    end

    OpenTelemetry::Instrumentation::Rails::Instrumentation.instance.install
    OpenTelemetry::Instrumentation::ActiveRecord::Instrumentation.instance.install
    OpenTelemetry::Instrumentation::Net::HTTP::Instrumentation.instance.install
  end
end
