import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/src/features/whats_new/data/whats_new_repository.dart';
import 'package:openbudget_app/src/features/whats_new/providers/whats_new_providers.dart';
import 'package:openbudget_app/src/features/whats_new/screens/whats_new_sheet.dart';

/// Opens the What's new sheet once after an update.
///
/// Call this from the signed-in shell's build. It does nothing on the first
/// launch, when the stored version matches, or when the release has no notes
/// file. The version is recorded after the sheet closes, so a dismissed sheet
/// still counts as shown.
void useWhatsNewAutoPrompt(BuildContext context, WidgetRef ref) {
  final prompt = ref.watch(whatsNewAutoPromptProvider);
  final hasShown = useRef(false);

  useEffect(() {
    if (hasShown.value) {
      return null;
    }

    final result = prompt.value;
    if (result is! WhatsNewNotesAvailable) {
      return null;
    }

    hasShown.value = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) {
        return;
      }
      unawaited(_openSheet(context, ref, result));
    });
    return null;
  }, [prompt, context, ref]);
}

Future<void> _openSheet(
  BuildContext context,
  WidgetRef ref,
  WhatsNewNotesAvailable result,
) async {
  await showWhatsNewSheet(context, result: result);
  if (!context.mounted) {
    return;
  }
  await ref.read(whatsNewSeenVersionProvider.notifier).markSeen(result.version);
}
