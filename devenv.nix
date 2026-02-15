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

  scripts = {
    "flutter" = {
      exec = ''
        set -e
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
    "update:deps" = {
      exec = ''
        set -e
        devenv update
        flutter pub upgrade
      '';
      description = "Update all project dependencies.";
    };
    "fix:all" = {
      exec = ''
        set -e
        fix:format
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
    "lint:all" = {
      exec = ''
        set -e
        lint:format
        melos analyze
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
      description = "The `dart format` executable for formatting the workspace.";
      binary = "bash";
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
    "server:start" = {
      exec = ''
        set -e
        cd "$DEVENV_ROOT/openbudget_server"
        dart bin/main.dart --apply-migrations
      '';
      description = "Start the Serverpod development server.";
    };
  };
}
