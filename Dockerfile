FROM elixir:1.11-alpine as builder

# Install SSL ca certificates
RUN apk update && \
  apk add ca-certificates && \
  apk add curl && \
  apk add bash

# Create appuser
RUN adduser -D -g '' appuser

# Get the source code
WORKDIR /elixir-representer
COPY . .

# Builds an escript bin/elixir_representer
RUN ./bin/build.sh

FROM elixir:1.11-alpine
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /usr/local/bin/tooling_webserver /usr/local/bin/tooling_webserver
COPY --from=builder /elixir-representer/bin /opt/representer/bin
RUN apk update && \
  apk add bash
USER appuser
WORKDIR /opt/representer
ENTRYPOINT ["/opt/representer/bin/run.sh"]
