import 'package:flutter/material.dart';

import '../../widgets/app_chrome.dart';
import '../../widgets/public_blocks.dart';

class PricingPage extends StatelessWidget {
  const PricingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PublicShell(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pricing',
              style: Theme.of(context)
                  .textTheme
                  .displaySmall
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            const Text(
              'Transparent monthly verified-contact limits. No customer-facing vendor credit math.',
            ),
            const SizedBox(height: 28),
            const PricingGrid(),
          ],
        ),
      ),
    );
  }
}
