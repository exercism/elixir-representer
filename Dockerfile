FROM hexpm/elixir:1.20.1-erlang-29.0-debian-bookworm-20260610 AS builder

# Install SSL ca certificates
RUN apt-get update && \
  apt-get install -y bash

# Create appuser
RUN useradd -ms /bin/bash appuser

# Get the source code
WORKDIR /elixir-representer
COPY . .

# Builds an escript bin/elixir_representer
RUN ./bin/build.sh

FROM hexpm/elixir:1.20.1-erlang-29.0-debian-bookworm-20260610
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /elixir-representer/bin /opt/representer/bin
RUN apt-get update && \
  apt-get install -y bash
USER appuser
WORKDIR /opt/representer
ENTRYPOINT ["/opt/representer/bin/run.sh"]
