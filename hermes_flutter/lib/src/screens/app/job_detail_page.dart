import 'dart:async';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/hermes_models.dart';
import '../../providers.dart';
import '../../widgets/app_chrome.dart';

class JobDetailPage extends ConsumerStatefulWidget {
  const JobDetailPage({super.key, required this.jobId});

  final String jobId;

  @override
  ConsumerState<JobDetailPage> createState() => _JobDetailPageState();
}

class _JobDetailPageState extends ConsumerState<JobDetailPage> {
  final _recipeName = TextEditingController(text: 'My recipe');
  Timer? _timer;
  int _refresh = 0;
  String? _message;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) setState(() => _refresh++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recipeName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Job detail',
      child: FutureBuilder<String?>(
        future: ref.read(authRepositoryProvider).tokenFor(context),
        builder: (context, token) {
          if (!token.hasData) return const CircularProgressIndicator();
          final repo = ref.read(hermesRepositoryProvider);
          return FutureBuilder<(LeadJob, LeadList)>(
            key: ValueKey(_refresh),
            future: () async {
              final job = await repo.job(token.data, widget.jobId);
              final leads = await repo.jobResults(token.data, widget.jobId);
              return (job, leads);
            }(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return ErrorCard(message: snapshot.error.toString());
              }
              final job = snapshot.data!.$1;
              final leads = snapshot.data!.$2.items;
              final progress = job.progressJson ?? const {};
              final verified = (progress['verified'] as num?)?.toDouble() ?? 0;
              final target =
                  (progress['target_verified'] as num?)?.toDouble() ?? 1;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  job.id,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ),
                              Chip(label: Text(job.status)),
                            ],
                          ),
                          const SizedBox(height: 14),
                          LinearProgressIndicator(
                            value: (verified / target).clamp(0, 1),
                          ),
                          const SizedBox(height: 8),
                          Text('Verified: ${verified.toInt()} / ${target.toInt()}'),
                          if (job.error != null) ...[
                            const SizedBox(height: 10),
                            ErrorCard(message: job.error!),
                          ],
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              OutlinedButton.icon(
                                onPressed: job.isRunning
                                    ? () async {
                                        await repo.cancelJob(
                                            token.data, widget.jobId);
                                        setState(() => _refresh++);
                                      }
                                    : null,
                                icon: const Icon(Icons.cancel_outlined),
                                label: const Text('Cancel'),
                              ),
                              FilledButton.icon(
                                onPressed: () => _export(token.data),
                                icon: const Icon(Icons.download),
                                label: const Text('Export CSV'),
                              ),
                              SizedBox(
                                width: 240,
                                child: TextField(
                                  controller: _recipeName,
                                  decoration: const InputDecoration(
                                    labelText: 'Recipe name',
                                  ),
                                ),
                              ),
                              FilledButton.tonalIcon(
                                onPressed: () => _saveRecipe(token.data, job),
                                icon: const Icon(Icons.bookmark_add_outlined),
                                label: const Text('Save recipe'),
                              ),
                            ],
                          ),
                          if (_message != null) ...[
                            const SizedBox(height: 10),
                            Text(_message!),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _LeadsTable(leads: leads),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _export(String? token) async {
    try {
      final bytes =
          await ref.read(hermesRepositoryProvider).exportJobCsv(token, widget.jobId);
      await FileSaver.instance.saveFile(
        name: 'job-${widget.jobId}',
        bytes: bytes,
        fileExtension: 'csv',
        mimeType: MimeType.csv,
      );
      setState(() => _message = 'CSV exported.');
    } catch (error) {
      setState(() => _message = error.toString());
    }
  }

  Future<void> _saveRecipe(String? token, LeadJob job) async {
    try {
      await ref.read(hermesRepositoryProvider).createRecipe(
            token,
            name: _recipeName.text.trim(),
            paramsJson: job.paramsJson,
            notes: 'Saved from job ${job.id}',
          );
      setState(() => _message = 'Recipe saved.');
    } catch (error) {
      setState(() => _message = error.toString());
    }
  }
}

class _LeadsTable extends StatelessWidget {
  const _LeadsTable({required this.leads});

  final List<Lead> leads;

  @override
  Widget build(BuildContext context) {
    if (leads.isEmpty) {
      return const EmptyCard(message: 'No results yet.');
    }
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Company')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Phone')),
            DataColumn(label: Text('Score')),
          ],
          rows: [
            for (final lead in leads)
              DataRow(cells: [
                DataCell(Text(lead.name.isEmpty ? '-' : lead.name)),
                DataCell(Text(lead.company ?? '-')),
                DataCell(Text(lead.email ?? '-')),
                DataCell(Text(lead.phone ?? '-')),
                DataCell(Text('${lead.scoreInt ?? '-'}')),
              ]),
          ],
        ),
      ),
    );
  }
}
