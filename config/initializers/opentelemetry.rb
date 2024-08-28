require 'opentelemetry/sdk'
require 'opentelemetry/exporter/file_exporter'

# Custom sanitizer to ensure and fix UTF-8 encoding
def sanitize_utf8(input)
  case input
  when String
    input.encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
  when Array
    input.map { |v| sanitize_utf8(v) }
  when Hash
    input.transform_values { |v| sanitize_utf8(v) }
  else
    input
  end
end

require 'logger'

class SanitizingSpanProcessor
  def initialize(span_processor)
    @span_processor = span_processor
    @logger = Logger.new('log/otel_debug.log')
  end

  def on_start(span, parent_context)
    @span_processor.on_start(span, parent_context)
  end

  def on_finish(span)
    begin
      original_attributes = span.to_h[:attributes]
      @logger.info("Original attributes: #{original_attributes.inspect}")
      
      sanitized_attributes = sanitize_utf8(original_attributes)
      @logger.info("Sanitized attributes: #{sanitized_attributes.inspect}")

      span.instance_variable_set(:@to_h, span.to_h.merge({ attributes: sanitized_attributes }))
    rescue => e
      @logger.error("Error sanitizing span attributes: #{e.message}")
      @logger.error(e.backtrace.join("\n"))
    end
    @span_processor.on_finish(span)
  end

  def shutdown
    @span_processor.shutdown
  end

  def force_flush
    @span_processor.force_flush
  end
end

OpenTelemetry::SDK.configure do |c|
  c.use_all

  file_exporter = OpenTelemetry::Exporter::FileExporter.new('log/otel_traces.json')

  c.add_span_processor(SanitizingSpanProcessor.new(
    OpenTelemetry::SDK::Trace::Export::SimpleSpanProcessor.new(file_exporter)
  ))
end