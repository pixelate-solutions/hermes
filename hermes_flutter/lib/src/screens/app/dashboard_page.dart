import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/hermes_models.dart';
import '../../providers.dart';
import '../../widgets/app_chrome.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppShell(
      title: 'Dashboard',
      child: FutureBuilder<String?>(
        future: ref.read(authRepositoryProvider).tokenFor(context),
        builder: (context, token) {
          if (!token.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final repo = ref.read(hermesRepositoryProvider);
          return FutureBuilder<(Me, JobList)>(
            future: () async {
              final me = await repo.me(token.data);
              final jobs = await repo.jobs(token.data, limit: 5);
              return (me, jobs);
            }(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return ErrorCard(message: snapshot.error.toString());
              }
              final data = snapshot.data!;
              final me = data.$1;
              final jobs = data.$2.items;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      SizedBox(
                        width: 260,
                        child: StatCard(
                          label: 'Plan',
                          value: me.plan.name,
                          icon: Icons.workspace_premium_outlined,
                        ),
                      ),
                      SizedBox(
                        width: 260,
                        child: StatCard(
                          label: 'Used',
                          value:
                              '${me.plan.verifiedContactsUsed}/${me.plan.monthlyContactCap}',
                          icon: Icons.verified_outlined,
                        ),
                      ),
                      SizedBox(
                        width: 260,
                        child: StatCard(
                          label: 'Remaining',
                          value: '${me.plan.verifiedContactsRemaining}',
                          icon: Icons.battery_charging_full_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Plan-aware lead generation',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 8),
                                Text('Workspace: ${me.orgName}'),
                              ],
                            ),
                          ),
                          FilledButton.icon(
                            onPressed: () => context.go('/app/leads/new'),
                            icon: const Icon(Icons.add),
                            label: const Text('New job'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Recent jobs',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  if (jobs.isEmpty)
                    const EmptyCard(message: 'No jobs yet.')
                  else
                    for (final job in jobs)
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.work_outline),
                          title: Text(job.status),
                          subtitle: Text(job.createdAt.toLocal().toString()),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.go('/app/leads/jobs/${job.id}'),
                        ),
                      ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
