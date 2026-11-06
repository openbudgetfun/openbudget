import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/ledger/ledger_labels.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// A journal's lifecycle state on a tone wash: draft, posted or reversed.
class JournalStatusChip extends HookWidget {
  const JournalStatusChip({required this.status, super.key});

  final JournalStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ObToneChip(
      label: ledgerStatusLabel(l10n, status),
      tone: ledgerStatusTone(status),
    );
  }
}
