import 'package:flutter/material.dart';

import '../../widgets/app_chrome.dart';
import '../../widgets/public_blocks.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PublicShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HeroBand(),
          _HowItWorksStrip(),
          SizedBox(height: 34),
          PricingGrid(),
          SizedBox(height: 56),
        ],
      ),
    );
  }
}

class _HowItWorksStrip extends StatelessWidget {
  const _HowItWorksStrip();

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.tune, 'Define', 'Industry, geography, roles, and company fit.'),
      (Icons.bolt, 'Generate', 'Apollo search, enrichment, verification, and scoring.'),
      (Icons.download, 'Export', 'CSV results and saved recipes for repeatable workflows.'),
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(item.$1),
                    const SizedBox(height: 12),
                    Text(
                      item.$2,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(item.$3),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
