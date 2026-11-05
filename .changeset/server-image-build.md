---
openbudget_server: fix
---

# Build the server image from the workspace and apply migrations on start

The server `Dockerfile` now narrows the root workspace to `openbudget_core`, `openbudget_lints` and `openbudget_server` before `dart pub get`, so the Dart-only build image no longer fails on the Flutter workspace members, and the committed `pubspec.lock` still pins every package. `.dockerignore` keeps `openbudget_lints` (a path dev dependency) and drops local `.dart_tool/` and `build/` output. The entrypoint passes `--apply-migrations`, so a new image never serves requests against an older schema.
