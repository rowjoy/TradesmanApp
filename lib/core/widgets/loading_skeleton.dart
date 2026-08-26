import 'package:flutter/material.dart';

/// Fixed-size loading placeholders keep the page geometry stable while data is
/// refreshed, avoiding spinner-to-content layout jumps.
class AppListSkeleton extends StatelessWidget {
  const AppListSkeleton({
    super.key,
    this.itemCount = 5,
    this.padding = const EdgeInsets.fromLTRB(16, 12, 16, 96),
  });

  final int itemCount;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: padding,
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => const AppCardSkeleton(),
    ),
  );
}

class AppCardSkeleton extends StatelessWidget {
  const AppCardSkeleton({super.key, this.height = 82});

  final double height;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(
      context,
    ).colorScheme.surfaceContainerHighest.withValues(alpha: .62);
    return RepaintBoundary(
      child: Container(
        height: height,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FractionallySizedBox(
                    widthFactor: .58,
                    child: Container(height: 12, color: color),
                  ),
                  const SizedBox(height: 10),
                  FractionallySizedBox(
                    widthFactor: .82,
                    child: Container(height: 9, color: color),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
