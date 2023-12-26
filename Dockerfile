FROM hexpm/elixir:1.16.0-erlang-26.2.1-debian-bookworm-20231009 as builder

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

FROM hexpm/elixir:1.16.0-erlang-26.2.1-debian-bookworm-20231009
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /elixir-representer/bin /opt/representer/bin
RUN apt-get update && \
  apt-get install -y bash
USER appuser
WORKDIR /opt/representer
ENTRYPOINT ["/opt/representer/bin/run.sh"]
