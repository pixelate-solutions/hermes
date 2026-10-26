import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/hermes_models.dart';
import '../../providers.dart';
import '../../widgets/app_chrome.dart';

class NewJobPage extends ConsumerStatefulWidget {
  const NewJobPage({super.key});

  @override
  ConsumerState<NewJobPage> createState() => _NewJobPageState();
}

class _NewJobPageState extends ConsumerState<NewJobPage> {
  final _industry = TextEditingController(text: 'Software');
  final _geo = TextEditingController(text: 'United States');
  final _roles = TextEditingController(text: 'Founder, Head of Sales');
  final _companySize = TextEditingController(text: '11-50');
  final _maxContacts = TextEditingController(text: '25');
  bool _includeEmail = true;
  bool _includePhone = false;
  int _step = 0;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _industry.dispose();
    _geo.dispose();
    _roles.dispose();
    _companySize.dispose();
    _maxContacts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'New lead job',
      child: FutureBuilder<String?>(
        future: ref.read(authRepositoryProvider).tokenFor(context),
        builder: (context, token) {
          if (!token.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return FutureBuilder<Me>(
            future: ref.read(hermesRepositoryProvider).me(token.data),
            builder: (context, meSnapshot) {
              if (!meSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final plan = meSnapshot.data!.plan;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Step ${_step + 1} of 5',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          Text('Remaining: ${plan.verifiedContactsRemaining}'),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Stepper(
                        currentStep: _step,
                        onStepTapped: (value) => setState(() => _step = value),
                        controlsBuilder: (context, details) => const SizedBox(),
                        steps: [
                          Step(
                            title: const Text('Market'),
                            isActive: _step == 0,
                            content: _fields([
                              _field(_industry, 'Industry'),
                              _field(_geo, 'Geography'),
                            ]),
                          ),
                          Step(
                            title: const Text('Buyer'),
                            isActive: _step == 1,
                            content: _fields([
                              _field(_roles, 'Roles, comma separated'),
                              _field(_companySize, 'Company size'),
                            ]),
                          ),
                          Step(
                            title: const Text('Volume'),
                            isActive: _step == 2,
                            content: _field(
                              _maxContacts,
                              'Max verified contacts',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          Step(
                            title: const Text('Reveal'),
                            isActive: _step == 3,
                            content: Column(
                              children: [
                                SwitchListTile(
                                  value: _includeEmail,
                                  onChanged: (value) =>
                                      setState(() => _includeEmail = value),
                                  title: const Text('Include verified email'),
                                ),
                                SwitchListTile(
                                  value: _includePhone && plan.allowsPhone,
                                  onChanged: plan.allowsPhone
                                      ? (value) => setState(
                                          () => _includePhone = value)
                                      : null,
                                  title: Text(plan.allowsPhone
                                      ? 'Include phone'
                                      : 'Include phone (Pro required)'),
                                ),
                              ],
                            ),
                          ),
                          Step(
                            title: const Text('Review'),
                            isActive: _step == 4,
                            content: _review(plan),
                          ),
                        ],
                      ),
                      if (_error != null) ErrorCard(message: _error!),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          OutlinedButton(
                            onPressed: _step == 0
                                ? null
                                : () => setState(() => _step -= 1),
                            child: const Text('Back'),
                          ),
                          const Spacer(),
                          if (_step < 4)
                            FilledButton(
                              onPressed: () => setState(() => _step += 1),
                              child: const Text('Next'),
                            )
                          else
                            FilledButton.icon(
                              onPressed: _saving
                                  ? null
                                  : () => _createJob(token.data, plan),
                              icon: const Icon(Icons.play_arrow),
                              label:
                                  Text(_saving ? 'Launching...' : 'Run job'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _fields(List<Widget> children) => Column(
        children: [
          for (final child in children) ...[child, const SizedBox(height: 12)],
        ],
      );

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget _review(PlanSnapshot plan) {
    final request = _request(plan);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Industry: ${request.industry}'),
        Text('Geo: ${request.geo}'),
        Text('Roles: ${request.roles.join(', ')}'),
        Text('Max contacts: ${request.maxContacts}'),
        Text('Email: ${request.includeVerifiedEmail ? 'Yes' : 'No'}'),
        Text('Phone: ${request.includePhone ? 'Yes' : 'No'}'),
      ],
    );
  }

  CreateLeadJobRequest _request(PlanSnapshot plan) {
    final remaining = plan.verifiedContactsRemaining.clamp(1, 5000);
    final max = int.tryParse(_maxContacts.text) ?? 1;
    return CreateLeadJobRequest(
      industry: _industry.text.trim(),
      geo: _geo.text.trim(),
      roles: _roles.text
          .split(',')
          .map((role) => role.trim())
          .where((role) => role.isNotEmpty)
          .toList(),
      companySize: _companySize.text.trim(),
      maxContacts: max.clamp(1, remaining),
      includeVerifiedEmail: _includeEmail,
      includePhone: plan.allowsPhone && _includePhone,
    );
  }

  Future<void> _createJob(String? token, PlanSnapshot plan) async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final job =
          await ref.read(hermesRepositoryProvider).createJob(token, _request(plan));
      if (mounted) context.go('/app/leads/jobs/${job.id}');
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
