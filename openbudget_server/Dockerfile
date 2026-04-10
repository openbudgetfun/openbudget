# Build stage — context must be the repo root so path dependencies resolve
FROM dart:3.11 AS build
WORKDIR /workspace
COPY . .

# Install dependencies and compile the server executable
WORKDIR /workspace/openbudget_server
RUN dart pub get
RUN dart compile exe bin/main.dart -o bin/server

# Final stage
FROM alpine:latest

# Environment variables
ENV runmode=production
ENV serverid=default
ENV logging=normal
ENV role=monolith

# Copy runtime dependencies
COPY --from=build /runtime/ /

# Copy compiled server executable
COPY --from=build /workspace/openbudget_server/bin/server server

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

# Define the entrypoint command
ENTRYPOINT ./server --mode=$runmode --server-id=$serverid --logging=$logging --role=$role
