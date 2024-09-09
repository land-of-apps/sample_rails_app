class OtelLoggerFormatter < Logger::Formatter
  def call(severity, time, progname, msg)
    span_context = OpenTelemetry::Trace.current_span.context
    trace_id = span_context.hex_trace_id
    span_id = span_context.hex_span_id
    trace_flags = span_context.trace_flags

    "[#{time}] #{severity} (trace_id=#{trace_id} span_id=#{span_id} trace_flags=#{trace_flags}): #{msg}\n"
  end
end
