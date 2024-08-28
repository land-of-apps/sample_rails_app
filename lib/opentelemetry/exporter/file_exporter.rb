require 'opentelemetry/sdk/trace/export'

module OpenTelemetry
  module Exporter
    class FileExporter < OpenTelemetry::SDK::Trace::Export::SimpleSpanProcessor
      def initialize(file_path)
        @file_path = file_path
      end

      def export(spans, timeout: nil)
        File.open(@file_path, 'a') do |file|
          spans.each do |span|
            # Ensure the span is UTF-8 encoded safely
            sanitized_span = sanitize_utf8(span.to_json)
            file.puts(sanitized_span)
          end
        end

        OpenTelemetry::SDK::Trace::Export::SUCCESS
      end

      private

      def sanitize_utf8(string)
        string.encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
      end
    end
  end
end