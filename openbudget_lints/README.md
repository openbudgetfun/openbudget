# openbudget_lints

Centralized lint rules for the OpenBudget project.

## Usage

Add to your package's `analysis_options.yaml`:

```yaml
include: package:openbudget_lints/analysis_options.yaml
```

## Enforced Rules

- `avoid_stateful_widgets`: Disallows classes that extend
  `StatefulWidget`, `ConsumerStatefulWidget`, or
  `StatefulHookConsumerWidget`.
- `enforce_pinned_app_dependencies`: In `openbudget_app/pubspec.yaml`,
  requires exact versions in `dependencies` and rejects constraints starting
  with `^`, `>`, or `~`.

## Enable Plugin Rules

To enable analyzer plugin rules in a package, add:

```yaml
plugins:
  openbudget_lints:
    path: ../openbudget_lints
```

For the workspace root package, use:

```yaml
plugins:
  openbudget_lints:
    path: ./openbudget_lints
```

## Rule Configuration

The analyzer plugin configuration model only supports plugin source
(`path`/`git`/`version`) and `diagnostics` severity toggles natively.
`openbudget_lints` reads additional keys from the same plugin block to support
rule-specific options.

You can override disallowed widget base classes per package:

```yaml
plugins:
  openbudget_lints:
    path: ../openbudget_lints
    disallowed_classes:
      - StatefulWidget
      - ConsumerStatefulWidget
      - StatefulHookConsumerWidget
      - CustomLegacyStatefulBase
```

Notes:

- If `disallowed_classes` is omitted, the default list above is used.
- If `disallowed_classes` is present, the configured list fully replaces the
  defaults.
