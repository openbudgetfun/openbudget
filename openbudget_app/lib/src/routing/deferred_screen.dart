import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/utils/load_problem_message.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// Builds a screen whose code lives in a deferred library.
///
/// On the web, dart2js splits each deferred library into its own file, which
/// the browser fetches the first time someone opens one of its screens, so
/// the app's first download carries only what the first screens need (see
/// `docs/performance.md`). Native builds compile deferred libraries into the
/// app and load them at once.
///
/// [library] names the deferred library and [load] is its `loadLibrary`.
/// A library loads once; after that its screens build straight away, with no
/// placeholder frame. A failed fetch shows a problem panel with Retry.
class DeferredScreen extends HookWidget {
  const DeferredScreen({
    required this.library,
    required this.load,
    required this.builder,
    super.key,
  });

  /// A stable name for the deferred library, such as `reports`.
  final String library;

  /// The library's `loadLibrary` tear-off.
  final Future<void> Function() load;

  /// Builds the screen once the library is loaded.
  final WidgetBuilder builder;

  static final _loaded = <String>{};
  static final _loading = <String, Future<void>>{};

  /// Whether [library] has finished loading.
  static bool isLoaded(String library) => _loaded.contains(library);

  /// Loads [library], sharing one fetch between callers. A failed fetch is
  /// forgotten, so the next call tries again.
  static Future<void> preload(String library, Future<void> Function() load) {
    if (_loaded.contains(library)) return Future.value();
    return _loading.putIfAbsent(library, () async {
      try {
        await load();
        _loaded.add(library);
      } finally {
        // Its callers already hold this future; the map only shares it
        // while the fetch is in flight.
        _loading.remove(library)?.ignore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final attempt = useState(0);
    final ready = isLoaded(library);
    final future = useMemoized(
      () => ready ? null : preload(library, load),
      [library, attempt.value],
    );
    final snapshot = useFuture(future);

    if (ready ||
        (snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasError)) {
      return builder(context);
    }

    final l10n = AppLocalizations.of(context);
    final error = snapshot.error;
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Center(
          child: error == null
              ? ObLoadingPanel(label: l10n.loadingTitle)
              : ObStatePanel.problem(
                  title: l10n.routerScreenLoadError,
                  message: loadProblemMessage(l10n, error),
                  action: ObStateAction(
                    label: l10n.homeRetry,
                    onPressed: () => attempt.value++,
                  ),
                ),
        ),
      ),
    );
  }
}
