import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HeroBand extends StatelessWidget {
  const HeroBand({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 56),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth > 860;
          return Flex(
            direction: wide ? Axis.horizontal : Axis.vertical,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: wide ? 6 : 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Chip(
                      avatar: const Icon(Icons.verified_outlined, size: 18),
                      label: const Text('Lead generation SaaS'),
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Verified leads in minutes, customized to your sales motion.',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            height: 1.04,
                          ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Define your niche, run an async lead job, and export clean verified contacts built for outbound teams.',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 28),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        FilledButton.icon(
                          onPressed: () => context.go('/sign-up'),
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('Get started'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => context.go('/enterprise'),
                          icon: const Icon(Icons.business_center_outlined),
                          label: const Text('Talk to sales'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (wide) const SizedBox(width: 36),
              Expanded(
                flex: wide ? 5 : 0,
                child: const PipelinePreview(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class PipelinePreview extends StatelessWidget {
  const PipelinePreview({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_graph, color: colors.primary),
                const SizedBox(width: 8),
                Text(
                  'Live lead job',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const LinearProgressIndicator(value: .72),
            const SizedBox(height: 18),
            const _PreviewRow('Search', 'Software, United States'),
            const _PreviewRow('Roles', 'Founder, Head of Sales'),
            const _PreviewRow('Verified', '72 / 100 contacts'),
            const _PreviewRow('Export', 'CSV ready'),
          ],
        ),
      ),
    );
  }
}

class PricingGrid extends StatelessWidget {
  const PricingGrid({super.key});

  @override
  Widget build(BuildContext context) {
    const plans = [
      ('Lite', r'$15/mo', '100 verified contacts', '1 recipe'),
      ('Starter', r'$25/mo', '300 verified contacts', '3 recipes'),
      ('Pro', r'$100/mo', '2,000 verified contacts', 'Phone reveal'),
      ('Enterprise', 'Custom', 'High-volume plans', 'SLA onboarding'),
    ];
    final isWide = MediaQuery.sizeOf(context).width > 880;

    final cards = [
      for (final plan in plans) _PricingCard(plan: plan),
    ];

    if (!isWide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final card in cards) ...[
            card,
            const SizedBox(height: 14),
          ],
        ],
      );
    }

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: .78,
      children: cards,
    );
  }
}

class _PricingCard extends StatelessWidget {
  const _PricingCard({required this.plan});

  final (String, String, String, String) plan;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              plan.$1,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              plan.$2,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 18),
            Text(plan.$3),
            Text(plan.$4),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: () =>
                  context.go(plan.$1 == 'Enterprise' ? '/enterprise' : '/sign-up'),
              child: Text(plan.$1 == 'Enterprise' ? 'Contact' : 'Choose'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          SizedBox(
            width: 86,
            child: Text(label, style: Theme.of(context).textTheme.labelLarge),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
