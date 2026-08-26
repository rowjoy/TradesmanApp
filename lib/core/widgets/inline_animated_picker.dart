import 'package:flutter/material.dart';

/// An in-page alternative to popup dropdowns.
///
/// Options expand inside the current layout with a short size/fade animation,
/// keeping context visible and preserving a single, predictable back action.
class InlineAnimatedPicker<T> extends StatefulWidget {
  const InlineAnimatedPicker({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.optionLabel,
    required this.onChanged,
    this.leading,
    this.optionLeading,
    this.enabled = true,
    this.maxExpandedHeight = 320,
  });

  final String label;
  final T value;
  final List<T> options;
  final String Function(T value) optionLabel;
  final ValueChanged<T> onChanged;
  final Widget? leading;
  final Widget Function(T value)? optionLeading;
  final bool enabled;
  final double maxExpandedHeight;

  @override
  State<InlineAnimatedPicker<T>> createState() =>
      _InlineAnimatedPickerState<T>();
}

class _InlineAnimatedPickerState<T> extends State<InlineAnimatedPicker<T>>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      expanded: _expanded,
      label: widget.label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _expanded ? colors.primary : colors.outlineVariant,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: widget.enabled
                  ? () => setState(() => _expanded = !_expanded)
                  : null,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                child: Row(
                  children: [
                    if (widget.leading != null) ...[
                      widget.leading!,
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.label,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(color: colors.onSurfaceVariant),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.optionLabel(widget.value),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: _expanded ? .5 : 0,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      child: const Icon(Icons.keyboard_arrow_down_rounded),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: _expanded
                  ? Column(
                      children: [
                        const Divider(height: 1),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: widget.maxExpandedHeight,
                          ),
                          child: ListView(
                            primary: false,
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            children: [
                              for (final option in widget.options)
                                _OptionTile<T>(
                                  value: option,
                                  selected: option == widget.value,
                                  label: widget.optionLabel(option),
                                  leading: widget.optionLeading?.call(option),
                                  onTap: () {
                                    widget.onChanged(option);
                                    setState(() => _expanded = false);
                                  },
                                ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionTile<T> extends StatelessWidget {
  const _OptionTile({
    required this.value,
    required this.selected,
    required this.label,
    required this.onTap,
    this.leading,
  });

  final T value;
  final bool selected;
  final String label;
  final VoidCallback onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: selected
          ? Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: .45)
          : Colors.transparent,
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 12)],
          Expanded(child: Text(label)),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 160),
            child: selected
                ? Icon(
                    Icons.check_circle_rounded,
                    key: ValueKey(value),
                    color: Theme.of(context).colorScheme.primary,
                  )
                : const SizedBox(width: 24),
          ),
        ],
      ),
    ),
  );
}
