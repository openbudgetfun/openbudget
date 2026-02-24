{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

let
  isCI = builtins.getEnv "CI" != "";
in
{
  packages =
    with pkgs;
    [
      dprint
      eget
      fvm
      gitleaks
      nixfmt
      nodejs_22
      shfmt
    ]
    ++ lib.optionals stdenv.isDarwin [
      coreutils
    ];

  env = {
    EGET_CONFIG = "${config.env.DEVENV_ROOT}/.eget/.eget.toml";
  };

  dotenv.disableHint = true;

  git-hooks = {
    package = pkgs.prek;

    hooks = {
      "secrets:commit" = {
        enable = true;
        name = "secrets:commit";
        description = "Scan staged changes for leaked secrets with gitleaks.";
        entry = "${pkgs.gitleaks}/bin/gitleaks protect --staged --verbose --redact --config .gitleaks.toml";
        pass_filenames = false;
        stages = [ "pre-commit" ];
      };
      "secrets:push" = {
        enable = true;
        name = "secrets:push";
        description = "Check entire git history for leaked secrets with gitleaks.";
        entry = "${pkgs.gitleaks}/bin/gitleaks detect --verbose --redact --config .gitleaks.toml";
        pass_filenames = false;
        stages = [ "pre-push" ];
      };
      format = {
        enable = true;
        name = "format";
        description = "Format files with dprint before commit.";
        entry = "${pkgs.dprint}/bin/dprint fmt --allow-no-files";
        stages = [ "pre-commit" ];
      };
      lint = {
        enable = true;
        name = "lint";
        description = "Run linting and formatting checks on every commit.";
        entry = "${config.env.DEVENV_PROFILE}/bin/dart analyze --fatal-infos";
        pass_filenames = true;
        always_run = true;
        stages = [ "pre-commit" ];
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
      settings = {
        log_connections = true;
        log_statement = "all";
      };
    };

    # In CI, Docker containers provide redis.
    redis = {
      enable = !isCI;
      port = 8091;
    };
  };

  processes = {
    "server:up" = {
      exec = ''
        server:start
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
    "knope" = {
      exec = ''
        set -e
        $DEVENV_ROOT/.eget/bin/knope $@
      '';
      description = "The knope executable for changeset and release management.";
      binary = "bash";
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
    "install:all" = {
      exec = ''
        set -e
        install:eget
        install:pulumi
        install:pnpm
        install:dart
        install:infra || echo "Skipping infra install (pnpm not available)"
      '';
      description = "Run all install scripts.";
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
    "install:eget" = {
      exec = ''
        HASH=$(nix hash path --base32 ./.eget/.eget.toml)
        echo "HASH: $HASH"
        if [ ! -f ./.eget/bin/hash ] || [ "$HASH" != "$(cat ./.eget/bin/hash)" ]; then
          echo "Updating eget binaries"
          eget -D --to "$DEVENV_ROOT/.eget/bin"
          echo "$HASH" > ./.eget/bin/hash
        else
          echo "eget binaries are up to date"
        fi
      '';
      description = "Install github binaries with eget.";
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
    "install:pnpm" = {
      exec = ''
        PNPM_DIR="$DEVENV_ROOT/.eget/bin"
        PNPM_VERSION="10.30.2"
        if [ -f "$PNPM_DIR/pnpm" ]; then
          CURRENT=$("$PNPM_DIR/pnpm" --version 2>/dev/null || echo "")
          if [ "$CURRENT" = "$PNPM_VERSION" ]; then
            echo "pnpm $PNPM_VERSION already installed"
            exit 0
          fi
        fi
        echo "Installing pnpm $PNPM_VERSION..."
        OS=$(uname -s | tr '[:upper:]' '[:lower:]')
        ARCH=$(uname -m | sed 's/x86_64/x64/' | sed 's/aarch64/arm64/')
        curl -fsSL "https://github.com/pnpm/pnpm/releases/download/v$PNPM_VERSION/pnpm-$OS-$ARCH" -o "$PNPM_DIR/pnpm"
        chmod +x "$PNPM_DIR/pnpm"
        echo "pnpm $PNPM_VERSION installed"
      '';
      description = "Install pnpm standalone binary.";
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
    "pnpm" = {
      exec = ''
        set -e
        $DEVENV_ROOT/.eget/bin/pnpm $@
      '';
      description = "Run pnpm package manager.";
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
        cd "$DEVENV_ROOT/openbudget_app"
        flutter test integration_test
      '';
      description = "Run Patrol integration tests.";
    };
    "lint:analyze" = {
      exec = ''
        set -e
        dart analyze --fatal-infos .
      '';
      description = "Run dart analyze across the workspace in a single process.";
    };
    "lint:all" = {
      exec = ''
        set -e
        lint:format
        lint:analyze
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
        format:all
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
