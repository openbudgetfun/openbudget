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
  final bytes =
      await _captureViaIntegrationBinding(tester, name) ??
      await _captureViaRenderView(tester) ??
      await _captureViaRepaintBoundary(tester);

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
  // ignore: avoid_print, reason: exposes generated artifact path in CI/test logs.
  print('Saved screenshot: $screenshotPath');
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
