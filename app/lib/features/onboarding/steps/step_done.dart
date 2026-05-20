import 'package:flutter/material.dart';

import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/widgets.dart';

class StepDone extends StatelessWidget {
  const StepDone({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: T.space7),
            NeuSurface(
              depth: NeuDepth.raised,
              size: NeuSize.lg,
              borderRadius: BorderRadius.circular(80),
              padding: const EdgeInsets.all(T.space7),
              child: const Icon(
                Icons.celebration_rounded,
                size: 56,
                color: T.success,
              ),
            ),
            const SizedBox(height: T.space7),
            Text("You're set", style: T.display2, textAlign: TextAlign.center),
            const SizedBox(height: T.space3),
            Text(
              'The dashboard shows live readings. The Chat tab is your AI '
              'assistant — it will need a one-time download from Settings to '
              'come fully online.',
              style: T.bodySoft,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: T.space5),
          ],
        ),
      ),
    );
  }
}
