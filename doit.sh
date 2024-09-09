# After getting the rails application setup and working do the following to get OTEL output

## Open Docker Desktop
docker run -d --name jaeger \
  -e COLLECTOR_ZIPKIN_HOST_PORT=:9411 \
  -e COLLECTOR_OTLP_ENABLED=true \
  -p 6831:6831/udp \
  -p 6832:6832/udp \
  -p 5778:5778 \
  -p 16686:16686 \
  -p 4317:4317 \
  -p 4318:4318 \
  -p 14250:14250 \
  -p 14268:14268 \
  -p 14269:14269 \
  -p 9411:9411 \
  jaegertracing/all-in-one:latest

bundle install

env OTEL_EXPORTER_OTLP_ENDPOINT="http://localhost:4318" bundle exec rails server -p 8080

## Open the rails app
open http://127.0.0.1:8080

## Navigate around the applciation to generate some traces

## Open the Jaeger UI
open http://localhost:16686

Search for the service name "SampleRailsApp" and you should see traces being generated.

# To get spans into files

docker pull otel/opentelemetry-collector:latest

docker run \
  -v $(pwd)/otel-collector-config.yaml:/otel-config.yaml \
  -p 4317:4317 \
  -p 4318:4318 \
  -p 55679:55679 \
  -v .:/project \
  otel/opentelemetry-collector:latest \
  --config /otel-config.yaml


OTEL_EXPORTER_OTLP_ENDPOINT="http://localhost:4318" \
OTEL_LOGS_EXPORTER="otlp" \
OTEL_EXPORTER_OTLP_LOGS_ENDPOINT="http://localhost:4318" \
OTEL_RESOURCE_ATTRIBUTES="service.name=sample_rails_app" \
bundle exec rails server -p 8080
