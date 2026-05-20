import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';
import 'neu_button.dart';
import 'neu_surface.dart';

/// Reusable empty / disconnected / not-yet-set-up state.
class NeuEmptyState extends StatelessWidget {
  const NeuEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.tone = T.primary,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NeuSurface(
              depth: NeuDepth.raised,
              size: NeuSize.lg,
              borderRadius: BorderRadius.circular(80),
              padding: const EdgeInsets.all(T.space7),
              child: Icon(icon, size: T.iconXl + 8, color: tone),
            ),
            const SizedBox(height: T.space6),
            Text(title, style: T.h1, textAlign: TextAlign.center),
            const SizedBox(height: T.space2),
            Text(message, style: T.bodySoft, textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: T.space6),
              NeuButton(label: actionLabel!, onPressed: onAction, variant: NeuButtonVariant.filled),
            ],
          ],
        ),
      ),
    );
  }
}
