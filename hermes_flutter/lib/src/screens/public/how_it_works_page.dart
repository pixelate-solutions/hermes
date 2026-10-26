import 'package:flutter/material.dart';

import '../../widgets/app_chrome.dart';

class HowItWorksPage extends StatelessWidget {
  const HowItWorksPage({super.key});

  @override
  Widget build(BuildContext context) {
    const steps = [
      ('Define', 'Set industry, geography, roles, and company profile.'),
      ('Generate', 'Hermes runs search, enrichment, verified reveal, scoring, and quota controls.'),
      ('Export', 'Download deduped results and save recipes for repeatable jobs.'),
    ];
    return PublicShell(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How Hermes Works',
              style: Theme.of(context)
                  .textTheme
                  .displaySmall
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 26),
            for (var i = 0; i < steps.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${i + 1}')),
                    title: Text(steps[i].$1),
                    subtitle: Text(steps[i].$2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
