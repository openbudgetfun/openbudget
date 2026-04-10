{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

let
  isCI = builtins.getEnv "CI" != "";
  extra = inputs.ifiokjr-nixpkgs.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  packages =
    with pkgs;
    [
      dprint
      extra.agave
      extra.knope
      extra.mdt
      extra.pnpm-standalone
      fvm
      gitleaks
      ktlint
      nixfmt
      pulumi-bin
      pulumi-esc
      shfmt
    ]
    ++ lib.optionals stdenv.isDarwin [
      coreutils
      swiftformat
      swiftlint
    ];

  dotenv.disableHint = true;

  # Ensure redis-cli health probes authenticate against local development redis.
  env.REDISCLI_AUTH = "PTpOute8-systr4hDRsD6biK5x06B7Vv";

  git-hooks = {
    package = pkgs.prek;

    hooks = {
      # ── Pre-commit: fast gates ─────────────────────────────────────
      "format:check" = {
        enable = true;
        name = "format:check";
        description = "Fail if any file is not properly formatted (dprint + dart format).";
        entry = "${pkgs.dprint}/bin/dprint check";
        pass_filenames = false;
        stages = [ "pre-commit" ];
      };

      "secrets:commit" = {
        enable = true;
        name = "secrets:commit";
        description = "Scan staged changes for leaked secrets with gitleaks.";
        entry = "${pkgs.gitleaks}/bin/gitleaks protect --staged --verbose --redact --config .gitleaks.toml";
        pass_filenames = false;
        stages = [ "pre-commit" ];
      };

      "lint:commit" = {
        enable = true;
        name = "lint:commit";
        description = "Run dart analyze (fatal-infos) on the workspace.";
        entry = "${config.env.DEVENV_PROFILE}/bin/dart analyze --fatal-infos";
        pass_filenames = false;
        always_run = true;
        stages = [ "pre-commit" ];
      };

      # ── Pre-push: thorough gates ───────────────────────────────────
      "secrets:push" = {
        enable = true;
        name = "secrets:push";
        description = "Scan entire git history for leaked secrets before push.";
        entry = "${pkgs.gitleaks}/bin/gitleaks detect --verbose --redact --config .gitleaks.toml";
        pass_filenames = false;
        stages = [ "pre-push" ];
      };

      "lint:push" = {
        enable = true;
        name = "lint:push";
        description = "Run full lint suite (format, swift, l10n, analyze) before push.";
        entry = builtins.toString (
          pkgs.writeShellScript "lint-push" ''
            set -e
            export PATH="${config.env.DEVENV_PROFILE}/bin:$PATH"
            ${pkgs.dprint}/bin/dprint check
            ${config.env.DEVENV_PROFILE}/bin/dart analyze --fatal-infos
          ''
        );
        pass_filenames = false;
        always_run = true;
        stages = [ "pre-push" ];
      };

      "test:push" = {
        enable = true;
        name = "test:push";
        description = "Run full test suite before push.";
        entry = builtins.toString (
          pkgs.writeShellScript "test-push" ''
            set -e
            export PATH="${config.env.DEVENV_PROFILE}/bin:$PATH"
            ${config.env.DEVENV_PROFILE}/bin/dart run melos run test --no-select
          ''
        );
        pass_filenames = false;
        always_run = true;
        stages = [ "pre-push" ];
      };
    };
  };

  # Rely on the global sdk for now as the nix apple sdk is not working for me.
  apple.sdk = null;

  services = {
    # In CI, Docker containers provide postgres.
    postgres = {
      enable = !isCI;
      package = pkgs.postgresql_16;
      listen_addresses = "127.0.0.1";
      port = 8090;
      initialDatabases = [
        { name = "openbudget"; }
        { name = "openbudget_test"; }
      ];
      extensions = extensions: [
        extensions.pgvector
        extensions.postgis
        extensions.timescaledb
      ];
      settings = {
        log_connections = true;
        log_statement = "all";
      };
    };

    # In CI, Docker containers provide redis.
    redis = {
      enable = !isCI;
      port = 8091;
      # Keep local redis auth aligned with openbudget_server/config/passwords.yaml (development.redis).
      extraConfig = ''
        requirepass PTpOute8-systr4hDRsD6biK5x06B7Vv
      '';
    };
  };

  processes = {
    "flutter:up" = {
      exec = ''
        set -eo pipefail

        GENERATED_ENV_FILE="$DEVENV_ROOT/.tmp/flutter.env"
        if [[ -f "$GENERATED_ENV_FILE" ]]; then
          # shellcheck disable=SC1090
          source "$GENERATED_ENV_FILE"
        fi

        if [[ -n "''${OPENBUDGET_API_URL:-}" ]]; then
          if [[ -n "''${DEVICE_ID:-}" ]]; then
            flutter:app run -d "$DEVICE_ID" --dart-define="OPENBUDGET_API_URL=$OPENBUDGET_API_URL"
          else
            flutter:app run --dart-define="OPENBUDGET_API_URL=$OPENBUDGET_API_URL"
          fi
        else
          if [[ -n "''${DEVICE_ID:-}" ]]; then
            flutter:app run -d "$DEVICE_ID"
          else
            flutter:app run
          fi
        fi
      '';
      process-compose = {
        depends_on = lib.optionalAttrs (!isCI) {
          "postgres".condition = "process_healthy";
          "redis".condition = "process_healthy";
        };
        # is_interactive = true;
        log_configuration = {
          flush_each_line = true;
        };
      };
    };

    "server:up" = {
      exec = ''
        server:start
      '';
      process-compose = {
        # Devenv service processes are named after the service keys.
        # In CI, these services are disabled, so skip hard dependencies.
        depends_on = lib.optionalAttrs (!isCI) {
          "postgres".condition = "process_healthy";
          "redis".condition = "process_healthy";
        };
      };
    };
  };

  process = {
    managers.process-compose = {
      settings = {
        log_location = "${config.env.DEVENV_ROOT}/.tmp/log.txt";
        log_configuration = {
          add_timestamp = true;
        };
      };
    };
  };

  scripts = {
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
    "dart" = {
      exec = ''
        set -e
        fvm dart $@
      '';
      description = "Run dart commands.";
    };
    "flutter:app" = {
      exec = ''
        set -e
        cd "$DEVENV_ROOT/openbudget_app"
        flutter $@
      '';
      description = "Run flutter commands from the openbudget_app directory.";
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
        dart run serverpod_cli $@
      '';
      description = "Run the serverpod cli.";
    };
    "openbudget:url:update" = {
      exec = ''
        set -e
        cd "$DEVENV_ROOT"
        dart run openbudget_scripts:update_dev_server_url "$@"
      '';
      description = "Generate OPENBUDGET_API_URL for local flutter runs.";
      binary = "bash";
    };
    "start:up" = {
      exec = ''
        set -euo pipefail

        POSTGRES_DATA_DIR="$DEVENV_ROOT/.devenv/state/postgres"
        POSTMASTER_PID_FILE="$POSTGRES_DATA_DIR/postmaster.pid"
        PROCESS_PID_FILE="$DEVENV_ROOT/.devenv/processes.pid"
        RUN_DIR="$(readlink "$DEVENV_ROOT/.devenv/run" 2>/dev/null || true)"
        PROCESS_COMPOSE_SOCKET=""
        if [[ -n "$RUN_DIR" ]]; then
          PROCESS_COMPOSE_SOCKET="$RUN_DIR/pc.sock"
        fi

        # Ensure we don't run two process-compose sessions for the same project.
        devenv processes down >/dev/null 2>&1 || true

        pid_is_running() {
          local pid="$1"
          kill -0 "$pid" 2>/dev/null
        }

        kill_pid() {
          local pid="$1"

          if ! pid_is_running "$pid"; then
            return 0
          fi

          kill "$pid" 2>/dev/null || true
          for _ in {1..20}; do
            if ! pid_is_running "$pid"; then
              return 0
            fi
            sleep 0.1
          done

          kill -9 "$pid" 2>/dev/null || true
        }

        kill_matching_pids() {
          local pattern="$1"
          local pids
          pids="$(pgrep -f "$pattern" 2>/dev/null || true)"
          if [[ -z "$pids" ]]; then
            return 0
          fi

          while IFS= read -r pid; do
            [[ -z "$pid" ]] && continue
            kill_pid "$pid"
          done <<< "$pids"
        }

        kill_matching_pids "devenv-processes-postgres"
        kill_matching_pids "devenv-processes-redis"
        kill_matching_pids "devenv-processes-server-up"
        kill_matching_pids "devenv-processes-flutter-up"
        if [[ -n "$PROCESS_COMPOSE_SOCKET" ]]; then
          process_compose_pids="$(lsof -t "$PROCESS_COMPOSE_SOCKET" 2>/dev/null || true)"
          if [[ -n "$process_compose_pids" ]]; then
            while IFS= read -r process_compose_pid; do
              [[ -z "$process_compose_pid" ]] && continue
              kill_pid "$process_compose_pid"
            done <<< "$process_compose_pids"
          fi
        fi

        for port in 8080 8081 8082 8090 8091; do
          port_pids="$(lsof -tiTCP:$port -sTCP:LISTEN 2>/dev/null || true)"
          if [[ -n "$port_pids" ]]; then
            while IFS= read -r port_pid; do
              [[ -z "$port_pid" ]] && continue
              kill_pid "$port_pid"
            done <<< "$port_pids"
          fi
        done

        if [[ -f "$POSTMASTER_PID_FILE" ]]; then
          lock_pid="$(head -n1 "$POSTMASTER_PID_FILE" 2>/dev/null || true)"
          if [[ ! "$lock_pid" =~ ^[0-9]+$ ]] || ! pid_is_running "$lock_pid"; then
            echo "Removing stale postgres lock file..."
            rm -f "$POSTMASTER_PID_FILE"
          fi
        fi

        if [[ -f "$PROCESS_PID_FILE" ]]; then
          process_pid="$(cat "$PROCESS_PID_FILE" 2>/dev/null || true)"
          if [[ ! "$process_pid" =~ ^[0-9]+$ ]] || ! pid_is_running "$process_pid"; then
            echo "Removing stale devenv processes PID file..."
            rm -f "$PROCESS_PID_FILE"
          fi
        fi

        openbudget:url:update development

        exec devenv up "$@"
      '';
      description = "Start devenv after cleaning stale local postgres/redis state.";
      binary = "bash";
    };
    "install:all" = {
      exec = ''
        set -e
        install:pulumi
        install:pnpm
        install:dart
        install:infra || echo "Skipping infra install (pnpm not available)"
      '';
      description = "Run all install scripts.";
      binary = "bash";
    };
    "install:pnpm" = {
      exec = ''
        set -euo pipefail
        mkdir -p "$DEVENV_ROOT/.eget/bin"

        if ! command -v pnpm >/dev/null 2>&1; then
          echo "pnpm is not available in PATH."
          exit 127
        fi

        ln -sf "$(command -v pnpm)" "$DEVENV_ROOT/.eget/bin/pnpm"
      '';
      description = "Ensure pnpm is available for install scripts.";
      binary = "bash";
    };
    "install:dart" = {
      exec = ''
        set -e
        flutter pub get
      '';
      description = "Install dart dependencies";
      binary = "bash";
    };
    "install:pulumi" = {
      exec = ''
        PULUMI_DIR="$DEVENV_ROOT/.eget/bin"
        PULUMI_VERSION="v3.223.0"
        if [ -f "$PULUMI_DIR/pulumi" ]; then
          CURRENT=$("$PULUMI_DIR/pulumi" version 2>/dev/null || echo "")
          if [ "$CURRENT" = "$PULUMI_VERSION" ]; then
            echo "Pulumi $PULUMI_VERSION already installed"
            exit 0
          fi
        fi
        echo "Installing Pulumi $PULUMI_VERSION..."
        OS=$(uname -s | tr '[:upper:]' '[:lower:]')
        ARCH=$(uname -m | sed 's/x86_64/x64/' | sed 's/aarch64/arm64/')
        curl -fsSL "https://get.pulumi.com/releases/sdk/pulumi-$PULUMI_VERSION-$OS-$ARCH.tar.gz" \
          | tar xz --strip-components=1 -C "$PULUMI_DIR"
        echo "Pulumi $PULUMI_VERSION installed"
      '';
      description = "Install Pulumi CLI from official releases.";
      binary = "bash";
    };
    "install:infra" = {
      exec = ''
        set -e
        cd "$DEVENV_ROOT/infra"
        $DEVENV_ROOT/.eget/bin/pnpm install
      '';
      description = "Install infrastructure dependencies.";
      binary = "bash";
    };
    "pulumi" = {
      exec = ''
        set -e
        export PATH="$DEVENV_ROOT/.eget/bin:$PATH"
        source "$HOME/.env.dotfiles" 2>/dev/null || true
        export PULUMI_ACCESS_TOKEN="''${PULUMI_ACCESS_TOKEN:-$PULUMI_TOKEN}"
        $DEVENV_ROOT/.eget/bin/pulumi $@
      '';
      description = "Run Pulumi infrastructure CLI.";
      binary = "bash";
    };
    "esc" = {
      exec = ''
        set -e
        source "$HOME/.env.dotfiles" 2>/dev/null || true
        export PULUMI_ACCESS_TOKEN="''${PULUMI_ACCESS_TOKEN:-$PULUMI_TOKEN}"
        $DEVENV_ROOT/.eget/bin/esc $@
      '';
      description = "Run Pulumi ESC CLI.";
      binary = "bash";
    };
    "docs:workflows:update" = {
      exec = ''
        set -e
        mdt update
      '';
      description = "Sync markdown workflow templates into guide docs.";
      binary = "bash";
    };
    "docs:workflows:check" = {
      exec = ''
        set -e
        mdt check
      '';
      description = "Verify workflow markdown files are in sync with templates.";
      binary = "bash";
    };
    "infra:preview" = {
      exec = ''
        set -e
        cd "$DEVENV_ROOT/infra"
        pulumi preview $@
      '';
      description = "Preview infrastructure changes.";
      binary = "bash";
    };
    "infra:up" = {
      exec = ''
        set -e
        cd "$DEVENV_ROOT/infra"
        pulumi up $@
      '';
      description = "Deploy infrastructure changes.";
      binary = "bash";
    };
    "infra:destroy" = {
      exec = ''
        set -e
        cd "$DEVENV_ROOT/infra"
        pulumi destroy $@
      '';
      description = "Tear down all infrastructure resources.";
      binary = "bash";
    };
    "infra:build" = {
      exec = ''
        set -e
        cd "$DEVENV_ROOT/infra"
        pnpm build
      '';
      description = "Type-check the infrastructure code.";
      binary = "bash";
    };
    "infra:stack" = {
      exec = ''
        set -e
        cd "$DEVENV_ROOT/infra"
        pulumi stack $@
      '';
      description = "Manage Pulumi stacks (select, ls, output, etc.).";
      binary = "bash";
    };
    "server:start" = {
      exec = ''
        set -e
        cd "$DEVENV_ROOT/openbudget_server"
        dart bin/main.dart --apply-migrations
      '';
      description = "Start the Serverpod development server.";
    };
    "test:all" = {
      exec = ''
        set -e
        test:flutter
        melos exec --scope="openbudget_core" -- dart test
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
        cd "$DEVENV_ROOT"
        ./tools/run_patrol_integration_tests.sh
      '';
      description = "Run Patrol integration tests.";
    };
    "lint:analyze" = {
      exec = ''
        set -e
        dart analyze --fatal-infos $DEVENV_ROOT
      '';
      description = "Run dart analyze across the workspace in a single process.";
    };
    "lint:l10n" = {
      exec = ''
        set -e
        cd "$DEVENV_ROOT"
        dart run tools/check_localized_ui_text.dart
      '';
      description = "Fail if hardcoded UI text is found outside l10n resources.";
    };
    "lint:all" = {
      exec = ''
        set -e
        lint:format
        lint:swift
        docs:workflows:check
        lint:l10n
        lint:analyze
      '';
      description = "Lint all project files.";
    };
    "lint:swift" = {
      exec = ''
        set -euo pipefail
        if ! command -v swiftlint >/dev/null 2>&1; then
          echo "swiftlint is unavailable on this platform; skipping Swift lint."
          exit 0
        fi
        swiftlint lint --strict --quiet --config "$DEVENV_ROOT/.swiftlint.yml"
      '';
      description = "Run swiftlint for Swift source files.";
    };
    "lint:format" = {
      exec = ''
        set -e
        dprint check
      '';
      description = "Check all formatting is correct.";
    };
    "dartfmt" = {
      exec = ''
        set -e
        dart format -o show $@ | head -n -1
      '';
      description = "The dart format executable for formatting the workspace.";
      binary = "bash";
    };
    "fix:all" = {
      exec = ''
        set -e
        fix:format
        fix:dart
      '';
      description = "Fix all fixable lint issues.";
    };
    "fix:dart" = {
      exec = ''
        set -e
        dart fix --apply
      '';
      description = "Fix dart lint issues";
    };
    "fix:format" = {
      exec = ''
        set -e
        dprint fmt --config "$DEVENV_ROOT/dprint.json"
      '';
      description = "Fix formatting for entire project.";
    };
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
    "icons:generate" = {
      exec = ''
        set -e
        cd "$DEVENV_ROOT/openbudget_app"
        flutter pub get
        dart run flutter_launcher_icons -f flutter_launcher_icons.yaml
      '';
      description = "Regenerate launcher icons from openbudget_app/flutter_launcher_icons.yaml after updating the primary OpenBudget logo PNG.";
    };
    "splash:generate" = {
      exec = ''
        set -e
        cd "$DEVENV_ROOT/openbudget_app"
        flutter pub get
        dart run flutter_native_splash:create --path=flutter_native_splash.yaml
      '';
      description = "Regenerate native splash assets from openbudget_app/flutter_native_splash.yaml for light and dark logo variants.";
    };
    "clean:all" = {
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
