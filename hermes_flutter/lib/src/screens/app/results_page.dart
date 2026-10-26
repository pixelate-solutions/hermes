import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/hermes_models.dart';
import '../../providers.dart';
import '../../widgets/app_chrome.dart';

class ResultsPage extends ConsumerStatefulWidget {
  const ResultsPage({super.key});

  @override
  ConsumerState<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends ConsumerState<ResultsPage> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Lead results',
      child: FutureBuilder<String?>(
        future: ref.read(authRepositoryProvider).tokenFor(context),
        builder: (context, token) {
          if (!token.hasData) return const CircularProgressIndicator();
          return Column(
            children: [
              TextField(
                controller: _search,
                decoration: InputDecoration(
                  labelText: 'Search results',
                  suffixIcon: IconButton(
                    onPressed: () => setState(() {}),
                    icon: const Icon(Icons.search),
                  ),
                ),
                onSubmitted: (_) => setState(() {}),
              ),
              const SizedBox(height: 14),
              AsyncPanel<LeadList>(
                future: ref
                    .read(hermesRepositoryProvider)
                    .results(token.data, q: _search.text),
                builder: (context, data) {
                  if (data.items.isEmpty) {
                    return const EmptyCard(message: 'No leads found.');
                  }
                  return Card(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Name')),
                          DataColumn(label: Text('Title')),
                          DataColumn(label: Text('Company')),
                          DataColumn(label: Text('Email')),
                          DataColumn(label: Text('Phone')),
                        ],
                        rows: [
                          for (final lead in data.items)
                            DataRow(cells: [
                              DataCell(Text(lead.name.isEmpty ? '-' : lead.name)),
                              DataCell(Text(lead.title ?? '-')),
                              DataCell(Text(lead.company ?? '-')),
                              DataCell(Text(lead.email ?? '-')),
                              DataCell(Text(lead.phone ?? '-')),
                            ]),
                        ],
                      ),
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
