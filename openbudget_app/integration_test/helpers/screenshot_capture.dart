import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

Future<void> captureIntegrationScreenshot(
  WidgetTester tester,
  String name,
) async {
  final captureBackend = _resolveCaptureBackend();
  final captureResult = await _captureWithBackendPreference(
    tester: tester,
    name: name,
    backend: captureBackend,
  );
  final bytes = captureResult.bytes;

  if (bytes == null || bytes.isEmpty) {
    // ignore: avoid_print, reason: keeps CI/test logs explicit when capture cannot run.
    print(
      'Skipping screenshot capture for $name: no supported capture backend',
    );
    return;
  }

  final screenshotRootFromEnv = Platform
      .environment['OPENBUDGET_SCREENSHOT_DIR']
      ?.trim();
  final screenshotRoot =
      screenshotRootFromEnv == null || screenshotRootFromEnv.isEmpty
      ? '${Directory.systemTemp.path}/openbudget_screenshots/runtime'
      : screenshotRootFromEnv;
  final screenshotDir = Directory(screenshotRoot);
  if (!screenshotDir.existsSync()) {
    screenshotDir.createSync(recursive: true);
  }

  final screenshotPath = '${screenshotDir.path}/$name.png';
  File(screenshotPath).writeAsBytesSync(bytes);
  // ignore: avoid_print, reason: documents which capture backend produced the artifact.
  print('Screenshot backend for $name: ${captureResult.backend}');
  // ignore: avoid_print, reason: exposes generated artifact path in CI/test logs.
  print('Saved screenshot: $screenshotPath');
}

_ScreenshotBackend _resolveCaptureBackend() {
  final override = Platform.environment['OPENBUDGET_SCREENSHOT_BACKEND']
      ?.trim();
  switch (override) {
    case 'integration':
      return _ScreenshotBackend.integration;
    case 'repaint':
      return _ScreenshotBackend.repaint;
    case 'render':
      return _ScreenshotBackend.renderView;
    default:
      return _ScreenshotBackend.auto;
  }
}

Future<_CaptureResult> _captureWithBackendPreference({
  required WidgetTester tester,
  required String name,
  required _ScreenshotBackend backend,
}) async {
  Future<_CaptureResult?> attempt(_ScreenshotBackend option) async {
    final bytes = switch (option) {
      _ScreenshotBackend.integration => await _captureViaIntegrationBinding(
        tester,
        name,
      ),
      _ScreenshotBackend.repaint => await _captureViaRepaintBoundary(tester),
      _ScreenshotBackend.renderView => await _captureViaRenderView(tester),
      _ScreenshotBackend.auto => null,
    };
    if (bytes == null || bytes.isEmpty) return null;
    return _CaptureResult(bytes: bytes, backend: option.name);
  }

  if (backend != _ScreenshotBackend.auto) {
    final forcedResult = await attempt(backend);
    if (forcedResult != null) return forcedResult;
  }

  const fallbackOrder = [
    _ScreenshotBackend.integration,
    _ScreenshotBackend.repaint,
    _ScreenshotBackend.renderView,
  ];
  for (final option in fallbackOrder) {
    final result = await attempt(option);
    if (result != null) {
      return result;
    }
  }

  return const _CaptureResult(bytes: null, backend: 'none');
}

Future<Uint8List?> _captureViaIntegrationBinding(
  WidgetTester tester,
  String name,
) async {
  final binding = tester.binding;
  if (binding is! IntegrationTestWidgetsFlutterBinding) {
    return null;
  }

  try {
    final bytes = await binding.takeScreenshot(name);
    return Uint8List.fromList(bytes);
  } catch (error) {
    if (error is MissingPluginException || error is UnimplementedError) {
      // ignore: avoid_print, reason: plugin is unavailable in flutter-tester; we fall back below.
      print('Screenshot plugin unavailable for $name; using repaint fallback');
      return null;
    }
    rethrow;
  }
}

Future<Uint8List?> _captureViaRepaintBoundary(WidgetTester tester) async {
  await tester.pump();

  final boundaries = find
      .byType(RepaintBoundary, skipOffstage: false)
      .evaluate()
      .map((element) => element.renderObject)
      .whereType<RenderRepaintBoundary>();

  RenderRepaintBoundary? largestBoundary;
  var largestArea = 0.0;

  for (final boundary in boundaries) {
    if (!boundary.hasSize) {
      continue;
    }
    final size = boundary.size;
    if (size.isEmpty || !size.isFinite) {
      continue;
    }
    final area = size.width * size.height;
    if (area > largestArea) {
      largestArea = area;
      largestBoundary = boundary;
    }
  }

  if (largestBoundary == null) {
    return null;
  }

  final pixelRatio = tester.view.devicePixelRatio > 0
      ? tester.view.devicePixelRatio
      : 1.0;
  final image = await largestBoundary.toImage(pixelRatio: pixelRatio);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  if (bytes == null) {
    return null;
  }

  return bytes.buffer.asUint8List();
}

Future<Uint8List?> _captureViaRenderView(WidgetTester tester) async {
  await tester.pump();

  final renderViews = tester.binding.renderViews;
  if (renderViews.isEmpty) {
    return null;
  }

  final renderView = renderViews.first;
  final layer = renderView.debugLayer;
  if (layer is! OffsetLayer) {
    return null;
  }

  final pixelRatio = tester.view.devicePixelRatio > 0
      ? tester.view.devicePixelRatio
      : 1.0;
  final image = await layer.toImage(
    renderView.paintBounds,
    pixelRatio: pixelRatio,
  );
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  if (bytes == null) {
    return null;
  }
  return bytes.buffer.asUint8List();
}

enum _ScreenshotBackend { auto, integration, repaint, renderView }

class _CaptureResult {
  const _CaptureResult({required this.bytes, required this.backend});

  final Uint8List? bytes;
  final String backend;
}
