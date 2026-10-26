import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/hermes_models.dart';
import '../../providers.dart';
import '../../widgets/app_chrome.dart';

class BillingPage extends ConsumerStatefulWidget {
  const BillingPage({super.key});

  @override
  ConsumerState<BillingPage> createState() => _BillingPageState();
}

class _BillingPageState extends ConsumerState<BillingPage> {
  String? _message;

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Billing',
      child: FutureBuilder<String?>(
        future: ref.read(authRepositoryProvider).tokenFor(context),
        builder: (context, token) {
          if (!token.hasData) return const CircularProgressIndicator();
          return AsyncPanel<BillingSummary>(
            future: ref.read(hermesRepositoryProvider).billing(token.data),
            builder: (context, billing) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current plan: ${billing.plan.name}',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Used ${billing.plan.verifiedContactsUsed} of ${billing.plan.monthlyContactCap}. Renewal ${billing.renewalDate.toLocal().toString().split(' ').first}.',
                        ),
                        Text('Stripe status: ${billing.stripeStatus ?? 'not subscribed'}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final plan in const [
                      ('lite', 'Lite - \$15/mo'),
                      ('starter', 'Starter - \$25/mo'),
                      ('pro', 'Pro - \$100/mo'),
                    ])
                      FilledButton(
                        onPressed: () => _openCheckout(token.data, plan.$1),
                        child: Text(plan.$2),
                      ),
                    OutlinedButton.icon(
                      onPressed: () => _openPortal(token.data),
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Manage portal'),
                    ),
                  ],
                ),
                if (_message != null) ...[
                  const SizedBox(height: 14),
                  Text(_message!),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  String get _platform {
    if (kIsWeb) return 'web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.android:
        return 'android';
      default:
        return 'web';
    }
  }

  Future<void> _openCheckout(String? token, String planCode) async {
    await _openUrl(() => ref
        .read(hermesRepositoryProvider)
        .checkout(token, planCode, _platform));
  }

  Future<void> _openPortal(String? token) async {
    await _openUrl(
        () => ref.read(hermesRepositoryProvider).billingPortal(token, _platform));
  }

  Future<void> _openUrl(Future<String> Function() loader) async {
    try {
      final url = await loader();
      final uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        setState(() => _message = 'Could not open billing page.');
      }
    } catch (error) {
      setState(() => _message = error.toString());
    }
  }
}
