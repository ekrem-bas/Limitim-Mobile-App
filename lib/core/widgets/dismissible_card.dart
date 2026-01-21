import 'package:flutter/material.dart';

class DismissibleCard extends StatelessWidget {
  final String id;
  final Widget child;
  final void Function(DismissDirection)? onDismissed;
  final DismissDirection direction;
  final EdgeInsets margin;
  final Widget? background;

  const DismissibleCard({
    super.key,
    required this.id,
    required this.child,
    this.onDismissed,
    this.direction = DismissDirection.endToStart,
    this.margin = const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(id),
      direction: direction,
      background: background ?? _defaultBackground(context),
      onDismissed: onDismissed,
      child: Card(margin: margin, elevation: 2, child: child),
    );
  }

  Widget _defaultBackground(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      margin: margin,
      child: Icon(
        Icons.delete_sweep,
        color: Theme.of(context).colorScheme.onError,
      ),
    );
  }
}
