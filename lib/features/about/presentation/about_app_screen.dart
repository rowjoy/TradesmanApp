import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_metadata_provider.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../l10n/l10n.dart';
import '../../app_review/application/app_review_providers.dart';
import '../../work/domain/work_models.dart';
import '../../work/presentation/controllers/work_controller.dart';
import '../domain/app_feature.dart';
import 'app_feature_catalog.dart';
import 'app_feature_navigation.dart';

class AboutAppScreen extends ConsumerWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metadata = ref.watch(appMetadataProvider);
    final canRateApp = ref.watch(storeListingSupportedProvider);
    final selectedWorkFlow = ref.watch(selectedWorkFlowProvider);
    final features = AppFeatureCatalog.all
        .where((feature) => feature.isAvailable)
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.aboutWorkProof)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth < 420 ? 12.0 : 20.0;
          final boundedWidth = constraints.maxWidth > 1120
              ? 1120.0
              : constraints.maxWidth;
          final contentWidth = math.max(
            0.0,
            boundedWidth - (horizontalPadding * 2),
          );
          final columns = contentWidth >= 900
              ? 3
              : contentWidth >= 600
              ? 2
              : 1;
          final cardWidth = columns == 1
              ? contentWidth
              : (contentWidth - ((columns - 1) * 12)) / columns;

          return ListView(
            key: const PageStorageKey('about-workproof'),
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              12,
              horizontalPadding,
              32,
            ),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: _AppInformationCard(
                    metadata: metadata,
                    onRateApp: canRateApp
                        ? () async {
                            try {
                              await ref
                                  .read(appReviewGatewayProvider)
                                  .openStoreListing();
                            } catch (_) {
                              if (context.mounted) {
                                AppFeedback.error(
                                  context,
                                  context.l10n.storeListingFailed,
                                );
                              }
                            }
                          }
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      context.l10n.appFeaturesTitle,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final feature in features)
                        SizedBox(
                          width: cardWidth,
                          child: _FeatureCard(
                            feature: feature,
                            workFlow: selectedWorkFlow,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AppInformationCard extends StatelessWidget {
  const _AppInformationCard({required this.metadata, this.onRateApp});

  final AsyncValue<AppMetadata> metadata;
  final VoidCallback? onRateApp;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Column(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.shadow.withValues(alpha: 0.18),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'playstore.png',
                width: 104,
                height: 104,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => ColoredBox(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: const SizedBox.square(
                    dimension: 104,
                    child: Icon(Icons.verified_user_outlined, size: 54),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          metadata.when(
            data: (value) => _AppNameAndVersion(
              appName: value.appName.trim().isEmpty
                  ? context.l10n.appTitle
                  : value.appName,
              version: value.versionWithBuild,
            ),
            loading: () => _AppNameAndVersion(
              appName: context.l10n.appTitle,
              loading: true,
            ),
            error: (_, __) =>
                _AppNameAndVersion(appName: context.l10n.appTitle),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Text(
              context.l10n.aboutAppDescription,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ),
          if (onRateApp != null) ...[
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: onRateApp,
              icon: const Icon(Icons.star_outline_rounded),
              label: Text(context.l10n.rateWorkProof),
            ),
          ],
        ],
      ),
    ),
  );
}

class _AppNameAndVersion extends StatelessWidget {
  const _AppNameAndVersion({
    required this.appName,
    this.version,
    this.loading = false,
  });

  final String appName;
  final String? version;
  final bool loading;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        appName,
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
      ),
      const SizedBox(height: 8),
      if (loading)
        const SizedBox.square(
          dimension: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
      else
        Text(
          version == null
              ? context.l10n.versionUnavailable
              : context.l10n.versionLabel(version!),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
    ],
  );
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.feature, required this.workFlow});

  final AppFeature feature;
  final WorkFlow workFlow;

  @override
  Widget build(BuildContext context) {
    final strings = context.l10n;
    final title = feature.title(strings);
    final shortDescription = feature.shortDescription(strings);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => feature.open(context, workFlow),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.secondaryContainer,
                foregroundColor: Theme.of(
                  context,
                ).colorScheme.onSecondaryContainer,
                child: Icon(feature.materialIcon),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      shortDescription,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: strings.featureDetails,
                onPressed: () => _showFeatureDetails(context),
                icon: const Icon(Icons.info_outline_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showFeatureDetails(BuildContext context) async {
    final strings = context.l10n;
    final openFeature = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        scrollable: true,
        icon: Icon(feature.materialIcon),
        title: Text(feature.title(strings)),
        content: Text(feature.description(strings)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(MaterialLocalizations.of(context).closeButtonLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(strings.openFeature),
          ),
        ],
      ),
    );
    if (openFeature == true && context.mounted) {
      feature.open(context, workFlow);
    }
  }
}
