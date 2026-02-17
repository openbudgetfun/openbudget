{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  packages =
    with pkgs;
    [
      curl
      dprint
      eget
      fvm
      libiconv
      nixfmt
      nushell
      shfmt
    ]
    ++ lib.optionals stdenv.isDarwin [
      coreutils
    ];

  android = {
    enable = true;
  };

  dotenv.disableHint = true;

  # Rely on the global sdk for now as the nix apple sdk is not working for me.
  apple.sdk = null;

  services.postgres = {
    enable = true;
    package = pkgs.postgresql_16;
    listen_addresses = "127.0.0.1";
    port = 8090;
    initialDatabases = [
      { name = "openbudget"; }
      { name = "openbudget_test"; }
    ];
    settings = {
      log_connections = true;
      log_statement = "all";
    };
  };

  services.redis = {
    enable = true;
    port = 8091;
  };

  processes = {
    "server:all" = {
      exec = ''
        cd "$DEVENV_ROOT/openbudget_server"
        dart bin/main.dart --apply-migrations
      '';
      process-compose = {
        depends_on = {
          "devenv-up-postgres".condition = "process_healthy";
          "devenv-up-redis".condition = "process_healthy";
        };
      };
    };
  };

  scripts = {
    # ── Core toolchain wrappers ──────────────────────────────────────────
    "flutter" = {
      exec = ''
        set -e
        # Unset Nix toolchain variables that conflict with Xcode builds
        unset CC CXX LD AR NM RANLIB STRIP OBJCOPY OBJDUMP SIZE STRINGS
        unset NIX_CC NIX_BINTOOLS NIX_CFLAGS_COMPILE NIX_LDFLAGS
        unset NIX_HARDENING_ENABLE NIX_ENFORCE_NO_NATIVE
        unset NIX_DONT_SET_RPATH NIX_DONT_SET_RPATH_FOR_BUILD NIX_NO_SELF_RPATH
        unset NIX_IGNORE_LD_THROUGH_GCC
        unset NIX_BINTOOLS_WRAPPER_TARGET_HOST_arm64_apple_darwin
        unset NIX_CC_WRAPPER_TARGET_HOST_arm64_apple_darwin
        unset NIX_PKG_CONFIG_WRAPPER_TARGET_HOST_arm64_apple_darwin
        unset SDKROOT MACOSX_DEPLOYMENT_TARGET
        unset CFLAGS CXXFLAGS LDFLAGS ARCHFLAGS
        unset PKG_CONFIG PKG_CONFIG_PATH
        unset LD_LIBRARY_PATH LD_DYLD_PATH
        unset cmakeFlags
        fvm flutter $@
      '';
      description = "Run flutter commands.";
    };
    "flutter:app" = {
      exec = ''
        set -e
        cd "$DEVENV_ROOT/openbudget_app"
        flutter $@
      '';
      description = "Run flutter commands from the openbudget_app directory.";
    };
    "dart" = {
      exec = ''
        set -e
        fvm dart $@
      '';
      description = "Run dart commands.";
    };
    "melos" = {
      exec = ''
        set -e
        dart run melos $@
      '';
      description = "Run the melos cli.";
    };
    "serverpod" = {
      exec = ''
        set -e
        dart run serverpod $@
      '';
      description = "Run the serverpod cli.";
    };

    # ── Services ─────────────────────────────────────────────────────────
    "server:start" = {
      exec = ''
        set -e
        cd "$DEVENV_ROOT/openbudget_server"
        dart bin/main.dart --apply-migrations
      '';
      description = "Start the Serverpod development server.";
    };

    # ── Testing ──────────────────────────────────────────────────────────
    "test:all" = {
      exec = ''
        set -e
        melos run test --no-select
      '';
      description = "Run tests in all packages.";
    };
    "test:flutter" = {
      exec = ''
        set -e
        melos run test:flutter --no-select
      '';
      description = "Run Flutter tests only.";
    };
    "test:integration" = {
      exec = ''
        set -e
        cd "$DEVENV_ROOT/openbudget_app"
        flutter test integration_test
      '';
      description = "Run Patrol integration tests.";
    };

    # ── Analysis & formatting ────────────────────────────────────────────
    "analyze" = {
      exec = ''
        set -e
        melos run analyze --no-select
      '';
      description = "Run dart analyze across all packages.";
    };
    "format" = {
      exec = ''
        set -e
        melos run format
        dprint fmt --config "$DEVENV_ROOT/dprint.json"
      '';
      description = "Format all code (Dart and non-Dart).";
    };
    "format:check" = {
      exec = ''
        set -e
        dprint check --config "$DEVENV_ROOT/dprint.json"
      '';
      description = "Check that all non-Dart formatting is correct.";
    };
    "lint:all" = {
      exec = ''
        set -e
        format:check
        analyze
      '';
      description = "Lint all project files.";
    };
    "lint:format" = {
      exec = ''
        set -e
        dprint check
      '';
      description = "Check all formatting is correct.";
    };
    "fix:all" = {
      exec = ''
        set -e
        format
      '';
      description = "Fix all fixable lint issues.";
    };
    "fix:format" = {
      exec = ''
        set -e
        dprint fmt --config "$DEVENV_ROOT/dprint.json"
      '';
      description = "Fix formatting for entire project.";
    };
    "dartfmt" = {
      exec = ''
        set -e
        dart format -o show $@ | head -n -1
      '';
      description = "The `dart format` executable for formatting the workspace.";
      binary = "bash";
    };

    # ── Code generation ──────────────────────────────────────────────────
    "runner:build" = {
      exec = ''
        set -e
        melos run generate
      '';
      description = "Run build_runner code generation.";
    };
    "runner:watch" = {
      exec = ''
        set -e
        melos run generate:watch
      '';
      description = "Run build_runner in watch mode.";
    };
    "runner:serverpod" = {
      exec = ''
        set -e
        melos run serverpod:generate
      '';
      description = "Run Serverpod code generation.";
    };

    # ── Utilities ────────────────────────────────────────────────────────
    "clean" = {
      exec = ''
        set -e
        melos run clean --no-select
      '';
      description = "Clean all Flutter packages.";
    };
    "update:deps" = {
      exec = ''
        set -e
        devenv update
        flutter pub upgrade
      '';
      description = "Update all project dependencies.";
    };
  };
}
