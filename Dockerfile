FROM hexpm/elixir:1.11.3-erlang-23.2.6-ubuntu-focal-20210119 as builder

# Install SSL ca certificates
RUN apt-get update && \
  apt-get install -y ca-certificates && \
  apt-get install -y curl && \
  apt-get install -y bash

# Create appuser
RUN useradd -ms /bin/bash appuser

# Get the source code
WORKDIR /elixir-representer
COPY . .

# Builds an escript bin/elixir_representer
RUN ./bin/build.sh

FROM hexpm/elixir:1.11.3-erlang-23.2.6-ubuntu-focal-20210119
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /elixir-representer/bin /opt/representer/bin
RUN apt-get update && \
  apt-get install -y bash
USER appuser
WORKDIR /opt/representer
ENTRYPOINT ["/opt/representer/bin/run.sh"]
