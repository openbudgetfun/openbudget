import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openbudget_core/openbudget_core.dart' show ChainFamily;
import 'package:openbudget_ui/openbudget_ui.dart';

/// Where to write the proof sheet. Unset, the sheet is only built, so a run
/// never leaves a file behind.
const _sheetPath = String.fromEnvironment('OB_CHAIN_STAMP_SHEET');

const _names = <ChainFamily, String>{
  ChainFamily.bitcoin: 'Bitcoin',
  ChainFamily.evm: 'Ethereum',
  ChainFamily.solana: 'Solana',
  ChainFamily.tron: 'Tron',
  ChainFamily.xrpl: 'XRP Ledger',
  ChainFamily.hyperliquid: 'Hyperliquid',
  ChainFamily.dogecoin: 'Dogecoin',
  ChainFamily.litecoin: 'Litecoin',
  ChainFamily.cardano: 'Cardano',
  ChainFamily.ton: 'TON',
  ChainFamily.sui: 'Sui',
  ChainFamily.aptos: 'Aptos',
};

/// One print run: every family inked and as an outline, then the picker.
class _Run extends HookWidget {
  const _Run({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final palette = theme.ob;
    return Theme(
      data: theme,
      child: Material(
        color: palette.canvas,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                theme.brightness == Brightness.light ? 'DAY RUN' : 'NIGHT RUN',
                style: ObTextStyles.stamp(
                  theme.textTheme.labelSmall,
                ).copyWith(color: palette.ink, fontSize: 12),
              ),
              const SizedBox(height: 12),
              for (final MapEntry(:key, :value) in _names.entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      ObChainStamp(family: key, label: value),
                      const SizedBox(width: 12),
                      ObChainStamp(family: key, label: value, inked: false),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  const ObChainStamp(
                    family: ChainFamily.bitcoin,
                    label: 'Bitcoin',
                    detail: 'zpub',
                  ),
                  const ObChainStamp(
                    family: ChainFamily.evm,
                    label: 'Ethereum',
                    detail: '+ 6',
                  ),
                  const ObChainStamp(
                    family: ChainFamily.evm,
                    label: 'Base',
                    value: '0.5000 ETH',
                  ),
                  const ObChainStamp(
                    family: ChainFamily.evm,
                    label: 'Arbitrum',
                    value: '0.0000 ETH',
                    inked: false,
                  ),
                  ObChainStampToggle(
                    family: ChainFamily.evm,
                    label: 'Optimism',
                    value: '1.2500 ETH',
                    selected: true,
                    onChanged: (_) {},
                  ),
                  ObChainStampToggle(
                    family: ChainFamily.evm,
                    label: 'Polygon',
                    value: '0.0000 POL',
                    selected: false,
                    onChanged: (_) {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tests draw in a block font unless told otherwise, so load the faces the
/// stamps are lettered in, to see the sheet as a person will.
Future<void> _loadSkribbleFaces() async {
  const package = 'packages/skribble_font_recursive';
  for (final (family, file) in const [
    (obStampFontFamily, 'SkribbleMonoPlayful-ExtraBold'),
    (obNumeralFontFamily, 'SkribbleLinearPlayful-Bold'),
    (obTextFontFamily, 'SkribbleLinearPlayful-ExtraBold'),
  ]) {
    final loader = FontLoader(family)
      ..addFont(rootBundle.load('$package/assets/fonts/$file.ttf'));
    await loader.load();
  }
}

void main() {
  testWidgets('proof sheet: every family, both states, both print runs', (
    tester,
  ) async {
    if (_sheetPath.isNotEmpty) {
      await tester.runAsync(_loadSkribbleFaces);
    }
    tester.view
      ..devicePixelRatio = 2
      ..physicalSize = const Size(960, 760) * 2;
    addTearDown(tester.view.reset);
    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: OpenBudgetTheme.light,
        home: ObWiredScope(
          child: RepaintBoundary(
            key: key,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _Run(theme: OpenBudgetTheme.light)),
                Expanded(child: _Run(theme: OpenBudgetTheme.dark)),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(ObChainStamp), findsNWidgets(2 * (12 * 2 + 4)));
    if (_sheetPath.isEmpty) {
      return;
    }
    await tester.runAsync(() async {
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      File(_sheetPath).writeAsBytesSync(bytes!.buffer.asUint8List());
    });
  });
}
