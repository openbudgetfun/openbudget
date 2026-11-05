# Build stage — context must be the repo root so path dependencies resolve
FROM dart:3.13 AS build
WORKDIR /workspace
COPY . .

# The root workspace also lists the Flutter packages, which this Dart-only
# image cannot resolve. Narrow it to the server and its path dependencies;
# the committed pubspec.lock keeps every remaining package at its locked
# version.
RUN printf '%s\n' \
  'name: openbudget_workspace' \
  'publish_to: none' \
  'environment:' \
  '  sdk: ^3.13.0' \
  'workspace:' \
  '  - openbudget_core' \
  '  - openbudget_lints' \
  '  - openbudget_server' \
  > pubspec.yaml

# Install dependencies and build the server. `dart build cli` (not
# `dart compile exe`) runs the native build hooks of `serverpod_argon2` and
# `sqlite3`, producing `bundle/bin/main` next to `bundle/lib/<libraries>`.
WORKDIR /workspace/openbudget_server
RUN dart pub get
RUN dart build cli --target bin/main.dart --output build/cli

# Final stage
FROM alpine:3.22

# Environment variables
ENV runmode=production
ENV serverid=default
ENV logging=normal
ENV role=monolith

# Copy runtime dependencies
COPY --from=build /runtime/ /

# The bundle keeps its own bin/ and lib/ under /app, so the executable finds
# its native libraries without touching the system directories.
WORKDIR /app
COPY --from=build /workspace/openbudget_server/build/cli/bundle/ ./

# Copy configuration files and resources
COPY --from=build /workspace/openbudget_server/config/ config/
COPY --from=build /workspace/openbudget_server/web/ web/
COPY --from=build /workspace/openbudget_server/migrations/ migrations/

# This file is required to enable the endpoint log filter in Insights.
COPY --from=build /workspace/openbudget_server/lib/src/generated/protocol.yaml lib/src/generated/protocol.yaml

# Expose ports
EXPOSE 8080
EXPOSE 8081
EXPOSE 8082

# Define the entrypoint command. Pending migrations are applied on start, so
# a new image never serves requests against an older schema.
ENTRYPOINT ./bin/main --mode=$runmode --server-id=$serverid --logging=$logging --role=$role --apply-migrations
