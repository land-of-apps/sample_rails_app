require 'opentelemetry/sdk'
require 'opentelemetry/exporter/file_exporter'
require 'logger'

# Custom sanitizer to ensure and fix UTF-8 encoding
class SanitizingSpanProcessor
  def initialize(span_processor)
    @span_processor = span_processor
    @logger = Logger.new(STDOUT)  # Initialize logger
  end

  def on_start(span, parent_context)
    # No customization needed on start, deferring to the original processor
    @span_processor.on_start(span, parent_context)
  end

  def on_finish(span)
    begin
      original_attributes = span.attributes
      @logger.info("Original attributes: #{original_attributes.inspect}")
      
      sanitized_attributes = sanitize_utf8(original_attributes)
      @logger.info("Sanitized attributes: #{sanitized_attributes.inspect}")

      span.instance_variable_set(:@attributes, sanitized_attributes)
    rescue => e
      @logger.error("Error sanitizing span attributes: #{e.message}")
      @logger.error(e.backtrace.join("\n"))
    end
    @span_processor.on_finish(span)
  end

  private

  def sanitize_utf8(attributes)
    # Ensure the attributes are UTF-8 encoded safely
    attributes.transform_values do |value|
      if value.is_a?(String)
        value.encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
      else
        value
      end
    end
  end
end

OpenTelemetry::SDK.configure do |c|
  c.use_all

  file_exporter = OpenTelemetry::Exporter::FileExporter.new('log/otel_traces.json')

  # Ensure the inner processor is passed correctly
  simple_processor = OpenTelemetry::SDK::Trace::Export::SimpleSpanProcessor.new(file_exporter)

  c.add_span_processor(SanitizingSpanProcessor.new(simple_processor))
end
