import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers.dart';
import '../../widgets/app_chrome.dart';

class JobsPage extends ConsumerStatefulWidget {
  const JobsPage({super.key});

  @override
  ConsumerState<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends ConsumerState<JobsPage> {
  String? _status;

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Lead jobs',
      child: FutureBuilder<String?>(
        future: ref.read(authRepositoryProvider).tokenFor(context),
        builder: (context, token) {
          if (!token.hasData) return const CircularProgressIndicator();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('All'),
                    selected: _status == null,
                    onSelected: (_) => setState(() => _status = null),
                  ),
                  for (final status in ['queued', 'running', 'completed', 'cancelled'])
                    ChoiceChip(
                      label: Text(status),
                      selected: _status == status,
                      onSelected: (_) => setState(() => _status = status),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              AsyncPanel(
                future: ref
                    .read(hermesRepositoryProvider)
                    .jobs(token.data, status: _status),
                builder: (context, data) {
                  if (data.items.isEmpty) {
                    return const EmptyCard(message: 'No jobs match this filter.');
                  }
                  return Card(
                    child: Column(
                      children: [
                        for (final job in data.items)
                          ListTile(
                            leading: Icon(job.isRunning
                                ? Icons.sync
                                : Icons.check_circle_outline),
                            title: Text(job.status),
                            subtitle: Text(job.createdAt.toLocal().toString()),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => context.go('/app/leads/jobs/${job.id}'),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
