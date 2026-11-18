import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/tax/providers/tax_providers.dart';
import 'package:openbudget_app/src/features/tax/providers/tax_url_launcher_provider.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// How many dates the list shows before the person asks for the rest.
const _collapsedCount = 4;

/// The "Upcoming" list: the next filing and payment dates for the budget,
/// each with what it is for, how far away it is and the authority page
/// behind it.
///
/// The list reads from the server's filing calendar, so it is the same for
/// every screen that shows it and never differs from the report's own rules.
class TaxUpcomingSection extends HookConsumerWidget {
  const TaxUpcomingSection({required this.entityId, super.key});

  final String entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final deadlinesAsync = ref.watch(taxDeadlinesProvider(entityId));
    final expanded = useState(false);

    return Column(
      key: const Key('tax-upcoming'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ObSectionHeader(
          title: l10n.taxUpcomingTitle,
          padding: const EdgeInsets.fromLTRB(
            0,
            SpacingTokens.lg,
            0,
            SpacingTokens.xs,
          ),
        ),
        deadlinesAsync.when(
          loading: () => Padding(
            padding: const EdgeInsets.symmetric(vertical: SpacingTokens.md),
            child: ObLoadingPanel(label: l10n.taxOverviewLoading),
          ),
          error: (error, _) => _UpcomingMessage(
            key: const Key('tax-upcoming-error'),
            text: l10n.taxUpcomingLoadError,
            actionLabel: l10n.taxCategoryLoadRetry,
            onAction: () => ref.invalidate(taxDeadlinesProvider(entityId)),
          ),
          data: (deadlines) {
            if (deadlines.isEmpty) {
              return _UpcomingMessage(
                key: const Key('tax-upcoming-empty'),
                text: l10n.taxUpcomingEmpty,
              );
            }
            final shown = expanded.value
                ? deadlines
                : deadlines.take(_collapsedCount).toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final deadline in shown)
                  _DeadlineCard(
                    key: Key(
                      'tax-deadline-${deadline.id}-${_dayKey(deadline.dueDate)}',
                    ),
                    deadline: deadline,
                  ),
                if (deadlines.length > _collapsedCount)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ObTextButton(
                      key: const Key('tax-upcoming-toggle'),
                      onPressed: () => expanded.value = !expanded.value,
                      child: Text(
                        expanded.value
                            ? l10n.taxUpcomingShowFewer
                            : l10n.taxUpcomingShowAll(deadlines.length),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// `20270131`, the day a deadline falls on, for widget keys.
String _dayKey(DateTime date) {
  final day = date.toUtc();
  return '${day.year}'
      '${day.month.toString().padLeft(2, '0')}'
      '${day.day.toString().padLeft(2, '0')}';
}

/// The calendar day of a server date, which is a UTC midnight, as a local
/// date so no time zone can move it to the day before.
DateTime _calendarDay(DateTime date) {
  final day = date.toUtc();
  return DateTime(day.year, day.month, day.day);
}

class _UpcomingMessage extends HookWidget {
  const _UpcomingMessage({
    required this.text,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ObCard(
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.ob.mutedInk,
            ),
          ),
          if (actionLabel != null)
            ObTextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

class _DeadlineCard extends HookConsumerWidget {
  const _DeadlineCard({required this.deadline, super.key});

  final TaxDeadlineView deadline;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final dueDate = DateFormat.yMMMd().format(_calendarDay(deadline.dueDate));
    final rolledFrom = deadline.rolledFrom;
    final note = deadline.note;

    return ObCard(
      margin: const EdgeInsets.only(bottom: SpacingTokens.xs),
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // The date and the days left share a line while they fit and wrap
          // apart at large text sizes; the title takes the full width below.
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: SpacingTokens.sm,
            runSpacing: SpacingTokens.xs,
            children: [
              Text(
                dueDate,
                key: const Key('tax-deadline-date'),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: palette.mutedInk,
                ),
              ),
              ObToneChip(
                key: const Key('tax-deadline-days-left'),
                label: l10n.taxUpcomingDaysLeft(deadline.daysLeft),
                tone: _toneFor(deadline.daysLeft),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            deadline.title,
            style: theme.textTheme.titleSmall?.copyWith(color: palette.ink),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            l10n.taxUpcomingPeriod(deadline.periodLabel),
            style: theme.textTheme.bodySmall?.copyWith(
              color: palette.mutedInk,
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Wrap(
            spacing: SpacingTokens.xs,
            runSpacing: SpacingTokens.xs,
            children: [
              ObToneChip(
                label: _kindLabel(l10n, deadline.kind),
                tone: ObTone.brand,
              ),
              if (deadline.dependsOnProfile)
                ObToneChip(
                  label: l10n.taxUpcomingDependsOnProfile,
                  tone: ObTone.review,
                ),
              if (deadline.grade != TaxEvidenceGrade.primary.name)
                ObToneChip(
                  key: const Key('tax-deadline-grade-badge'),
                  label: deadline.grade == TaxEvidenceGrade.secondary.name
                      ? l10n.taxSecondarySourceBadge
                      : l10n.taxUpcomingInferredBadge,
                  tone: ObTone.underfunded,
                ),
            ],
          ),
          if (rolledFrom != null) ...[
            const SizedBox(height: SpacingTokens.xs),
            Text(
              l10n.taxUpcomingMoved(
                DateFormat.yMMMd().format(_calendarDay(rolledFrom)),
              ),
              style: theme.textTheme.bodySmall?.copyWith(color: palette.ink),
            ),
          ],
          if (note != null) ...[
            const SizedBox(height: SpacingTokens.xs),
            Text(
              note,
              style: theme.textTheme.bodySmall?.copyWith(
                color: palette.mutedInk,
              ),
            ),
          ],
          const SizedBox(height: SpacingTokens.xs),
          Semantics(
            link: true,
            hint: l10n.taxUpcomingSourceHint,
            child: InkWell(
              key: const Key('tax-deadline-source'),
              borderRadius: BorderRadius.circular(RadiusTokens.sm),
              onTap: () => _openSource(context, ref, deadline.source),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: SpacingTokens.xs,
                ),
                child: Text(
                  l10n.taxUpcomingSource(deadline.citation),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: palette.brand,
                    decoration: TextDecoration.underline,
                    decorationColor: palette.brand,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Opens the authority page, telling the person in plain words when the
/// device has nothing to open it with.
Future<void> _openSource(
  BuildContext context,
  WidgetRef ref,
  String source,
) async {
  final message = AppLocalizations.of(context).taxLinkOpenFailed;
  final url = Uri.tryParse(source);
  var opened = false;
  if (url != null) {
    try {
      opened = await ref.read(taxUrlLauncherProvider).openPage(url);
    } on Exception {
      opened = false;
    }
  }
  if (!opened && context.mounted) {
    showAppToast(context, message: message, variant: AppToastVariant.error);
  }
}

/// Dates inside a week read as a warning, inside a month as something to
/// look at, and further off as plain information.
ObTone _toneFor(int daysLeft) {
  if (daysLeft <= 7) {
    return ObTone.underfunded;
  }
  if (daysLeft <= 30) {
    return ObTone.review;
  }
  return ObTone.neutral;
}

String _kindLabel(AppLocalizations l10n, String kind) =>
    switch (TaxDeadlineKind.values.asNameMap()[kind]) {
      TaxDeadlineKind.filing => l10n.taxUpcomingKindFiling,
      TaxDeadlineKind.payment => l10n.taxUpcomingKindPayment,
      TaxDeadlineKind.filingAndPayment => l10n.taxUpcomingKindFilingAndPayment,
      null => l10n.taxUpcomingKindFiling,
    };
